import 'package:flutter/material.dart';
import 'package:test1/page-1/all_bookings_artist.dart';
import 'package:test1/page-1/artist_inbox.dart';
import 'package:test1/page-1/page_0.3_artist_home.dart';
import 'package:test1/page-1/settings.dart';

class BottomNavart extends StatefulWidget {
  final Map<String, dynamic> data;
  final int initialPageIndex;
  final String? newBookingTitle;
  final String? newBookingDateTime;

  BottomNavart({
    required this.data,
    this.initialPageIndex = 0,
    this.newBookingTitle,
    this.newBookingDateTime,
  });

  @override
  State<BottomNavart> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNavart> {
  late int _currentIndex;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialPageIndex;
    _pages = [
      artist_home(),
      // artist_inbox(),
      AllBookings(
        data: widget.data,
        newBookingTitle: widget.newBookingTitle,
        newBookingDateTime: widget.newBookingDateTime,
      ),
      Setting(),
    ];
  }

  Future<bool> _onWillPop() async {
    // Return false to prevent back navigation
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return
      WillPopScope(
        onWillPop: _onWillPop,
        child :Scaffold(
          backgroundColor: Color(0xFF292938),
          body: _pages[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: Colors.black,
            selectedItemColor: Colors.white,
            unselectedItemColor: Color(0xFF9E9EB8),
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_filled),
                label: 'Home',
              ),
              // BottomNavigationBarItem(
              //   icon: Icon(Icons.mail_outline_outlined),
              //   activeIcon: Icon(Icons.mail_outline_outlined),
              //   label: 'Inbox',
              // ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_outlined),
                activeIcon: Icon(Icons.calendar_month),
                label: 'Bookings',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle_outlined),
                activeIcon: Icon(Icons.account_circle),
                label: 'Profile',
              ),
            ],
          ),
        ),
      );
  }
}
