// lib/config/routes.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../views/auth/splash_view.dart';
import '../views/auth/login_view.dart';
import '../views/auth/signup_view.dart';
import '../views/shared/main_navigation_view.dart';
import '../views/client/home_view.dart';
import '../views/client/search_view.dart';
import '../views/client/map_view.dart';
import '../views/client/listing_detail_view.dart';
import '../views/client/booking_view.dart';
import '../views/client/payment_confirmation_view.dart';
import '../views/host/add_listing_view.dart';
import '../views/shared/profile_view.dart';
import '../views/shared/booking_history_view.dart';
import '../controllers/auth_controller.dart';
import '../controllers/user_controller.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String main = '/main';
  static const String clientHome = '/client/home';
  static const String search = '/client/search';
  static const String map = '/client/map';
  static const String listingDetail = '/client/listing';
  static const String booking = '/client/booking';
  static const String paymentConfirmation = '/client/payment';
  static const String addListing = '/host/add-listing';
  static const String profile = '/profile';
  static const String bookingHistory = '/booking-history';

  static final routes = [
    GetPage(
      name: splash,
      page: () => SplashView(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: login,
      page: () => LoginView(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: signup,
      page: () => SignupView(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: main,
      page: () => MainNavigationView(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: search,
      page: () => SearchView(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: map,
      page: () => MapView(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '$listingDetail/:id',
      page: () => ListingDetailView(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: booking,
      page: () => BookingView(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: paymentConfirmation,
      page: () => PaymentConfirmationView(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: addListing,
      page: () => AddListingView(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: profile,
      page: () => ProfileView(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: bookingHistory,
      page: () => BookingHistoryView(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
      middlewares: [AuthMiddleware()],
    ),
  ];

  // Helper methods for navigation with parameters
  static void toListingDetail(String id, {dynamic arguments}) {
    Get.toNamed('$listingDetail/$id', arguments: arguments);
  }

  static void toBooking({dynamic arguments}) {
    Get.toNamed(booking, arguments: arguments);
  }

  static void toPaymentConfirmation({dynamic arguments}) {
    Get.toNamed(paymentConfirmation, arguments: arguments);
  }
}

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    try {
      final authController = Get.find<AuthController>();

      // If not logged in, redirect to login
      if (!authController.isLoggedIn) {
        return RouteSettings(name: AppRoutes.login);
      }

      // If user data is not loaded yet, redirect to splash
      final userController = Get.find<UserController>();
      if (userController.currentUser.value == null) {
        return RouteSettings(name: AppRoutes.splash);
      }

      return null; // Allow navigation
    } catch (e) {
      // Controllers not found, redirect to splash
      return RouteSettings(name: AppRoutes.splash);
    }
  }
}