import 'dart:async';
import 'dart:core';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test1/page-1/bottomNav_artist.dart';
import 'package:test1/page-1/bottom_nav.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api/firebase_api.dart';
import 'firebase_options.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import '../config.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:test1/page-1/page0.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// Providers
final authStateProvider = StateProvider<bool>((ref) => false);
final selectedValueProvider = StateProvider<String?>((ref) => null);
final connectivityProvider = StateProvider<ConnectivityResult>((ref) => ConnectivityResult.none);
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) => const FlutterSecureStorage());
final navigatorKeyProvider = Provider((ref) => GlobalKey<NavigatorState>());

// Global variables
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final FlutterSecureStorage secureStorage = FlutterSecureStorage();
bool authorised = false;
String? selectedValue = '';
StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;

Future<void> initializeApp() async {
  String? isInitialized = await secureStorage.read(key: 'isInitialized');

  if (isInitialized == null) {
    await secureStorage.deleteAll();
    await secureStorage.write(key: 'isInitialized', value: 'true');
  }
}

void firstinstall() async {
  final prefs = await SharedPreferences.getInstance();
  bool isFirstRun = prefs.getBool('first_run') ?? true;

  if (isFirstRun) {
    final storage = FlutterSecureStorage();
    await storage.deleteAll();

    String? isSignedUp = await storage.read(key: 'user_signup');
    print('mohit is cool $isSignedUp');
    await prefs.setBool('first_run', false);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeApp();


  try {
    firstinstall();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Firebase Crashlytics
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    await FirebaseApi().initNotification();
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  String? authStatus;
  try {
    authStatus = await secureStorage.read(key: 'authorised');
  } catch (e) {
    print("Error reading from secure storage: $e");
  }

  authorised = authStatus != null && authStatus == 'true';
  if (authorised) {
    selectedValue = await secureStorage.read(key: 'selected_value') ?? '';
  }

  runApp(
    ProviderScope(
      child: const MyAppWrapper(),
    ),
  );
}

class AppUpdateService {
  static final AppUpdateService _instance = AppUpdateService._internal();
  factory AppUpdateService() => _instance;
  AppUpdateService._internal();

  PackageInfo? _packageInfo;

  Future<PackageInfo> getPackageInfo() async {
    _packageInfo ??= await PackageInfo.fromPlatform();
    return _packageInfo!;
  }

  Future<void> checkAppVersion(BuildContext context) async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;
      String platform = Theme.of(context).platform == TargetPlatform.iOS ? 'ios' : 'android';

      final response = await http.get(
        Uri.parse('${Config().apiDomain}/app-version?platform=$platform'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final versionData = json.decode(response.body);
        String latestVersion = versionData['latest_version'];
        bool isForceUpdate = versionData['force_update'] ?? false;
        String storeUrl = versionData['update_url'];

        if (isUpdateRequired(currentVersion, latestVersion)) {
          _showUpdateDialog(context, latestVersion, isForceUpdate, storeUrl);
        }
      }
    } catch (e) {
      print('Version check error: $e');
    }
  }

  bool isUpdateRequired(String currentVersion, String latestVersion) {
    List<String> currentParts = currentVersion.split('.');
    List<String> latestParts = latestVersion.split('.');

    for (int i = 0; i < currentParts.length; i++) {
      int current = int.parse(currentParts[i]);
      int latest = int.parse(latestParts[i]);

      if (latest > current) return true;
      if (current > latest) return false;
    }
    return false;
  }

  void _showUpdateDialog(BuildContext context, String latestVersion, bool isForceUpdate, String storeUrl) {
    showDialog(
      context: context,
      barrierDismissible: !isForceUpdate,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xffe5195e).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.system_update,
                  color: Color(0xffe5195e),
                  size: 42,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Update Available',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'A new version ($latestVersion) of the app is available.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isForceUpdate)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.grey[800],
                          backgroundColor: Colors.grey[200],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Later',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  if (!isForceUpdate) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        launchUrl(
                          Uri.parse(storeUrl),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xffe5195e),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Update Now',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyAppWrapper extends ConsumerWidget {
  const MyAppWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PrimeStage',
      navigatorKey: ref.watch(navigatorKeyProvider),
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color(0xffe5195e),
          circularTrackColor: Color(0xffe5195e),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFFFEFEFE),
          shadowColor: const Color(0xFFE9E8E6).withOpacity(0.4),
          surfaceTintColor: Colors.transparent,
          elevation: 3,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFEFEFE),
          foregroundColor: Color(0xFFFEFEFE),
          elevation: 0,
          scrolledUnderElevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          iconTheme: IconThemeData(color: Colors.white),
          actionsIconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
          titleSpacing: NavigationToolbar.kMiddleSpacing,
          toolbarHeight: kToolbarHeight,
          toolbarTextStyle: TextStyle(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white)
            .copyWith(background: Colors.white),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
      ],
      home: const MyApp(),
    );
  }
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late Connectivity _connectivity;
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    _connectivity = Connectivity();
    _initConnectivity();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppUpdateService().checkAppVersion(context);
    });

    connectivitySubscription = _connectivity.onConnectivityChanged.listen(
          (List<ConnectivityResult> results) {
        if (results.isNotEmpty) {
          ref.read(connectivityProvider.notifier).state = results.first;
          _showConnectivitySnackbar(results.first);
        }
      },
    );
  }

  void _handleConnectivityChange(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      _showNoInternetDialog();
    } else {
      _dismissNoInternetDialog();
    }
  }

  void _showNoInternetDialog() {
    if (!_isDialogShowing && mounted) {
      _isDialogShowing = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              title: const Text('No Internet Connection'),
              content: const Text('Please check your internet connection.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _isDialogShowing = false;
                  },
                ),
              ],
            ),
          );
        },
      );
    }
  }

  void _dismissNoInternetDialog() {
    if (_isDialogShowing && mounted) {
      Navigator.of(context).pop();
      _isDialogShowing = false;
    }
  }

  Future<void> _initConnectivity() async {
    try {
      final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
      if (results.isNotEmpty) {
        ref.read(connectivityProvider.notifier).state = results.first;
      }
    } catch (e) {
      print('Failed to get connectivity status: $e');
    }
  }

  void _showConnectivitySnackbar(ConnectivityResult result) {
    String message;
    Color color;

    switch (result) {
      case ConnectivityResult.mobile:
        message = 'Connected to Mobile Network';
        color = Colors.green;
        break;
      case ConnectivityResult.wifi:
        message = 'Connected to Wi-Fi';
        color = Colors.green;
        break;
      case ConnectivityResult.none:
        message = 'No internet connection';
        color = Colors.red;
        break;
      default:
        message = 'Connectivity status unknown';
        color = Colors.grey;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAuthorized = ref.watch(authStateProvider);
    final selectedValueState = ref.watch(selectedValueProvider);

    return _getHomePage(isAuthorized, selectedValueState);
  }
  Widget _getHomePage(bool isAuthorized, String? selectedValueState) {
    if (!isAuthorized) {
      return Scene();
    }

    switch (selectedValueState) {
      case 'hire':
        return BottomNav();
      case 'solo_artist':
      case 'team':
        return BottomNavart(data: {});
      default:
        return Scene();
    }
  }
}

// Add a state notifier for managing app initialization
class AppInitializationNotifier extends StateNotifier<bool> {
  AppInitializationNotifier() : super(false);
  final storage = FlutterSecureStorage();

  Future<void> initializeApp(WidgetRef ref) async {
    if (state) return; // Already initialized

    String? authStatus = await storage.read(key: 'authorised');
    String? selectedValue = await storage.read(key: 'selected_value');

    // Update the auth state
    ref.read(authStateProvider.notifier).state = authStatus == 'true';

    // Update the selected value state
    if (authStatus == 'true') {
      ref.read(selectedValueProvider.notifier).state = selectedValue;
    }

    state = true; // Mark as initialized
  }
}

// Provider for app initialization
final appInitializationProvider = StateNotifierProvider<AppInitializationNotifier, bool>((ref) {
  return AppInitializationNotifier();
});

// Provider for managing connectivity status
final connectivityStatusProvider = StreamProvider<ConnectivityResult>((ref) {
  final connectivity = Connectivity();
  return connectivity.onConnectivityChanged.map((results) => results.first);
});

// Provider for app update service
final appUpdateServiceProvider = Provider((ref) => AppUpdateService());

// Provider for shared preferences
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

// Provider for handling first install
final firstInstallProvider = FutureProvider<void>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final storage = ref.watch(secureStorageProvider);

  bool isFirstRun = prefs.getBool('first_run') ?? true;

  if (isFirstRun) {
    await storage.deleteAll();
    await prefs.setBool('first_run', false);
  }
});

// Extension methods for easier state management
extension AppStateExtension on WidgetRef {
  Future<void> updateAuthState(bool isAuthorized) async {
    final storage = read(secureStorageProvider);
    await storage.write(key: 'authorised', value: isAuthorized.toString());
    read(authStateProvider.notifier).state = isAuthorized;
  }

  Future<void> updateSelectedValue(String value) async {
    final storage = read(secureStorageProvider);
    await storage.write(key: 'selected_value', value: value);
    read(selectedValueProvider.notifier).state = value;
  }

  Future<void> clearAppState() async {
    final storage = read(secureStorageProvider);
    await storage.deleteAll();
    read(authStateProvider.notifier).state = false;
    read(selectedValueProvider.notifier).state = null;
  }
}

// Error handling provider
final errorHandlingProvider = StateProvider<String?>((ref) => null);

// Provider for handling global app state
final globalAppStateProvider = StateNotifierProvider<GlobalAppStateNotifier, GlobalAppState>((ref) {
  return GlobalAppStateNotifier();
});

class GlobalAppState {
  final bool isLoading;
  final String? error;
  final bool isDarkMode;

  GlobalAppState({
    this.isLoading = false,
    this.error,
    this.isDarkMode = false,
  });

  GlobalAppState copyWith({
    bool? isLoading,
    String? error,
    bool? isDarkMode,
  }) {
    return GlobalAppState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

class GlobalAppStateNotifier extends StateNotifier<GlobalAppState> {
  GlobalAppStateNotifier() : super(GlobalAppState());

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void toggleDarkMode() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Firebase messaging provider
final firebaseMessagingProvider = Provider((ref) => FirebaseApi());

// Navigation service provider
class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey;

  NavigationService(this.navigatorKey);

  Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);
  }

  void goBack() {
    return navigatorKey.currentState!.pop();
  }
}

final navigationServiceProvider = Provider((ref) {
  return NavigationService(ref.watch(navigatorKeyProvider));
});