// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'controllers/auth_controller.dart';
import 'controllers/user_controller.dart';
import 'controllers/listing_controller.dart';
import 'controllers/booking_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
    // Continue with app initialization even if Firebase fails
  }

  // Initialize dependency injection
  await _initializeDependencies();

  runApp(MyApp());
}

Future<void> _initializeDependencies() async {
  print('Initializing dependencies...');

  try {
    // Initialize core controllers first
    Get.put(UserController(), permanent: true);
    print('UserController initialized');

    Get.put(AuthController(), permanent: true);
    print('AuthController initialized');

    // Initialize feature controllers as lazy singletons
    Get.lazyPut<ListingController>(() => ListingController(), fenix: true);
    Get.lazyPut<BookingController>(() => BookingController(), fenix: true);

    print('All controllers initialized successfully');
  } catch (e) {
    print('Error initializing dependencies: $e');
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Storage Space',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
      defaultTransition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 300),

      // Enhanced error handling
      unknownRoute: GetPage(
        name: '/not-found',
        page: () => _NotFoundPage(),
      ),

      // Routing callback for debugging
      routingCallback: (routing) {
        if (routing?.current != null) {
          print('Navigating to: ${routing!.current}');
        }
      },

      // Global error handling
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child ?? Container(),
        );
      },

      // Prevent system UI overlay style issues
      navigatorObservers: [
        _AppNavigatorObserver(),
      ],
    );
  }
}

class _NotFoundPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Page Not Found'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.error,
            ),
            SizedBox(height: 16),
            Text(
              '404 - Page Not Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Get.offAllNamed(AppRoutes.main);
              },
              child: Text('Go Home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    print('Navigation: Pushed ${route.settings.name}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    print('Navigation: Popped ${route.settings.name}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    print('Navigation: Replaced ${oldRoute?.settings.name} with ${newRoute?.settings.name}');
  }
}