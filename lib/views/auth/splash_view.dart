// lib/views/auth/splash_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/user_controller.dart';

class SplashView extends StatefulWidget {
  @override
  _SplashViewState createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  void _initializeApp() async {
    try {
      // Show splash for minimum time for UX
      await Future.delayed(Duration(seconds: 2));

      // Check if we've already navigated (auth controller might have handled it)
      if (_hasNavigated || !mounted) return;

      // Try to get controllers
      final authController = Get.find<AuthController>();
      final userController = Get.find<UserController>();

      // Wait for auth controller to be initialized
      int attempts = 0;
      while (!authController.isInitialized && attempts < 50) {
        await Future.delayed(Duration(milliseconds: 100));
        attempts++;
      }

      if (!mounted) return;

      // Check authentication state
      if (authController.isLoggedIn) {
        // User is logged in, check if user data is loaded
        if (userController.currentUser.value != null) {
          _navigateToMain();
        } else {
          // Try to load user data
          try {
            await userController.fetchCurrentUser(authController.currentAuthUser!.uid);
            if (userController.currentUser.value != null) {
              _navigateToMain();
            } else {
              _navigateToLogin();
            }
          } catch (e) {
            print('Splash: Failed to load user data - $e');
            _navigateToLogin();
          }
        }
      } else {
        _navigateToLogin();
      }
    } catch (e) {
      print('Splash: Error during initialization - $e');
      // Fallback to login if anything goes wrong
      _navigateToLogin();
    }
  }

  void _navigateToMain() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && Get.currentRoute == AppRoutes.splash) {
        Get.offAllNamed(AppRoutes.main);
      }
    });
  }

  void _navigateToLogin() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && Get.currentRoute == AppRoutes.splash) {
        Get.offAllNamed(AppRoutes.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.warehouse_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              ).animate()
                  .fadeIn(duration: 800.ms)
                  .scale(delay: 200.ms, duration: 600.ms),

              SizedBox(height: 32),

              // App Name
              Text(
                'Storage Space',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ).animate()
                  .fadeIn(delay: 400.ms, duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),

              SizedBox(height: 8),

              // Tagline
              Text(
                'Find your perfect storage',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                  letterSpacing: 0.5,
                ),
              ).animate()
                  .fadeIn(delay: 600.ms, duration: 600.ms),

              SizedBox(height: 80),

              // Loading Indicator
              Column(
                children: [
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ).animate()
                  .fadeIn(delay: 1000.ms, duration: 600.ms),

              // Version Info (optional)
              Spacer(),
              Padding(
                padding: EdgeInsets.only(bottom: 32),
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ).animate()
                  .fadeIn(delay: 1200.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}