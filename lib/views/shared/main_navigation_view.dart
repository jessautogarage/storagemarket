// lib/views/shared/main_navigation_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../controllers/user_controller.dart';
import '../../controllers/listing_controller.dart';
import '../../controllers/booking_controller.dart';
import '../client/home_view.dart' as client_home;
import '../host/dashboard_view.dart';
import '../host/manage_listings_view.dart';
import '../host/booking_requests_view.dart';
import 'booking_history_view.dart';
import 'profile_view.dart';

class MainNavigationView extends StatefulWidget {
  @override
  _MainNavigationViewState createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  final UserController userController = Get.find();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    Get.put(ListingController());
    Get.put(BookingController());
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = userController.currentUser.value;

      // Show loader while user data is loading
      if (user == null) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading...',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final isClient = user.userType == 'client';

      final clientPages = [
        client_home.HomeView(),
        BookingHistoryView(),
        ProfileView(),
      ];

      final hostPages = [
        DashboardView(),
        ManageListingsView(),
        BookingRequestsView(),
        ProfileView(),
      ];

      final pages = isClient ? clientPages : hostPages;

      return Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.secondaryText,
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
            items: isClient
                ? [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded, size: 28),
                label: 'Browse',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_rounded, size: 28),
                label: 'Bookings',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded, size: 28),
                label: 'Profile',
              ),
            ]
                : [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded, size: 28),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2_rounded, size: 28),
                label: 'Listings',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_rounded, size: 28),
                label: 'Bookings',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded, size: 28),
                label: 'Profile',
              ),
            ],
          ),
        ),
      );
    });
  }
}