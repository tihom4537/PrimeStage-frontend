import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../main.dart';
import '../page-1/all_bookings_artist.dart';
import '../page-1/artist_inbox.dart';
import '../page-1/bottomNav_artist.dart';
import '../page-1/bottom_nav.dart';
import '../page-1/user_bookings.dart';
// import 'package:firebase_iid/firebase_iid.dart';

Future <void> handleBackgroundMessage(RemoteMessage message) async{
  print('title: ${message.notification?.title}');
  print('body: ${message.notification?.body}');
  print('payload: ${message.data}');
  // print('type: ${message.data?.type}');
}

class FirebaseApi {
  final storage = FlutterSecureStorage();
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  final androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notification',
    importance: Importance.defaultImportance,
  );




  void handleMessage(RemoteMessage? message) {
    if (message == null) return;

    Map<String, dynamic> data = message.data;
    String? notificationTitle = message.notification?.title;
    String? notificationBody = message.notification?.body;
    String? bookingType = data['type'];

    print(bookingType);

    if (bookingType == 'artist') {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => BottomNavart(
            data: data,
            initialPageIndex: 2, // 2 is the index for AllBookings page
            newBookingTitle: notificationTitle,
            newBookingDateTime: notificationBody,
          ),
        ),
      );
    } else if (bookingType == 'user') {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => BottomNav(
            // data: data,
            initialPageIndex: 2, // Replace with appropriate index if different for UserBookings
            newBookingTitle: notificationTitle,
            newBookingDateTime: notificationBody,
          ),
        ),
      );
    } else if (bookingType == 'app') {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => BottomNavart(
            data: data,
            initialPageIndex: 1, // 1 is the index for artist_inbox page
          ),
        ),
      );
    }
  }



//   Future initLocalNotification() async {
//     // const iOS = iOSInitializationSettings();
//     const android = AndroidInitializationSettings('@drawable/android_logo');
//     const settings = InitializationSettings(android : android );
//
//     await _localNotifications.initialize(
//       settings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) {
//         if (response.payload != null) {
//           final message = RemoteMessage.fromMap(jsonDecode(response.payload!));
//           handleMessage(message);
//         }
//       },
//     );
//     final platform = _localNotifications.resolvePlatformSpecificImplementation<
//         AndroidFlutterLocalNotificationsPlugin>();
//     await  platform?.createNotificationChannel(androidChannel);
// }


  Future initLocalNotification() async {
    // Add iOS-specific settings
    const iOS = DarwinInitializationSettings();  // Use `iOSInitializationSettings` for Flutter versions < 3.0.0

    // Existing Android settings
    const android = AndroidInitializationSettings('@drawable/android_logo');

    // Combine both Android and iOS settings
    const settings = InitializationSettings(android: android, iOS: iOS);

    // Initialize the local notifications plugin
    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          final message = RemoteMessage.fromMap(jsonDecode(response.payload!));
          handleMessage(message);
        }
      },
    );

    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(androidChannel);
  }

  Future initPushNotification() async {
    final _localNotifications = FlutterLocalNotificationsPlugin();
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen((message){
      final notification =message.notification;
      if (notification == null) return;

      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
            android: AndroidNotificationDetails (
              androidChannel.id,
              androidChannel.name,
              channelDescription: androidChannel.description,
              icon: '@drawable/android_logo',
            )
        ),
        payload: jsonEncode(message.toMap()),
      );
    });

  }

  Future<void> initNotification() async {
    try {
      await _firebaseMessaging.requestPermission();
       final fCMToken = await _firebaseMessaging.getToken();
      //final fCMToken ='fNlJEWkG8kb9sC3GvtSmv1:APA91bEF2EaBwd1lAu1K2J1TF9LZdkgQtcQ1k-sVctaiCFFb2wB5rHpzCuCE8SpDNZEM3wGxmojuEMDm2Xp3XuIbB69bK7s0ECo9nM_8wHXcmFRgeev-QZQ';
      print('token is : $fCMToken');
      if (fCMToken != null) {
        print('token: $fCMToken');
        await storage.write( key: 'fCMToken', value: fCMToken);

      }
      initPushNotification();
      initLocalNotification();

    } catch (e) {
      // Handle the case where Firebase throws an exception
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      bool gotFBCrash = true;
      if (gotFBCrash) {
        try {
          final fCMToken = await FirebaseMessaging.instance.getToken();
        } catch (e) {
          // Handle the case where Firebase throws an exception again
          FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
        }
      }
    }
  }
}
Widget buildBottomNavart(Map<String, dynamic> data, int initialPageIndex) {
  return BottomNavart(
    data: data,
    initialPageIndex: initialPageIndex,
  );
}