// bottom_nav_state.dart

import 'package:video_player/video_player.dart';


// bottom_nav.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test1/page-1/search.dart';
import 'package:test1/page-1/settings.dart';
import 'package:test1/page-1/user_bookings.dart';
import 'package:test1/pages/home_user.dart';

class BottomNavState {
  final int currentIndex;
  final VideoPlayerController videoController;

  BottomNavState({
    required this.currentIndex,
    required this.videoController,
  });

  BottomNavState copyWith({
    int? currentIndex,
    VideoPlayerController? videoController,
  }) {
    return BottomNavState(
      currentIndex: currentIndex ?? this.currentIndex,
      videoController: videoController ?? this.videoController,
    );
  }
}

class BottomNavNotifier extends StateNotifier<BottomNavState> {
  BottomNavNotifier(int initialIndex) : super(
      BottomNavState(
        currentIndex: initialIndex,
        videoController: VideoPlayerController.asset('assets/page-1/images/search.mp4')
          ..initialize()
          ..setVolume(0)
          ..setLooping(true),
      )
  );

  void setIndex(int index) {
    if (index == 1) {
      state.videoController.play();
    } else {
      state.videoController.pause();
    }
    state = state.copyWith(currentIndex: index);
  }

  @override
  void dispose() {
    state.videoController.dispose();
    super.dispose();
  }
}

final bottomNavProvider = StateNotifierProvider.family<BottomNavNotifier, BottomNavState, int>(
      (ref, initialIndex) => BottomNavNotifier(initialIndex),
);



class BottomNav extends ConsumerStatefulWidget {
  final int initialPageIndex;
  final String? newBookingTitle;
  final String? newBookingDateTime;
  final String? isteam;

  BottomNav({
    this.isteam,
    this.initialPageIndex = 0,
    this.newBookingTitle,
    this.newBookingDateTime,
  });

  @override
  ConsumerState<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends ConsumerState<BottomNav> with WidgetsBindingObserver {
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bottomNavState = ref.read(bottomNavProvider(widget.initialPageIndex));

    _pages = [
      HomeUser(),
      Search(controller: bottomNavState.videoController),
      UserBookings(isteam: widget.isteam),
      Setting(),
    ];
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final videoController = ref.read(bottomNavProvider(widget.initialPageIndex)).videoController;
    if (state == AppLifecycleState.resumed) {
      videoController.play();
    } else if (state == AppLifecycleState.paused) {
      videoController.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavState = ref.watch(bottomNavProvider(widget.initialPageIndex));

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFF292938),
        body: _pages[bottomNavState.currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: bottomNavState.currentIndex,
          onTap: (index) {
            ref.read(bottomNavProvider(widget.initialPageIndex).notifier).setIndex(index);
          },
          selectedItemColor: Colors.white,
          unselectedItemColor: const Color(0xFF9E9EB8),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.black,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}