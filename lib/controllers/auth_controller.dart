// lib/controllers/auth_controller.dart
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import 'user_controller.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final UserController userController;

  Rx<User?> firebaseUser = Rx<User?>(null);
  RxBool isLoading = false.obs;
  RxBool _isInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    userController = Get.find<UserController>();
    _initializeAuth();
  }

  void _initializeAuth() {
    // Set initial state
    firebaseUser.value = _auth.currentUser;

    // Listen to auth state changes
    firebaseUser.bindStream(_auth.authStateChanges());

    // Handle auth state changes
    ever(firebaseUser, _handleAuthChanged);

    _isInitialized.value = true;
  }

  void _handleAuthChanged(User? user) async {
    // Skip if not initialized yet
    if (!_isInitialized.value) return;

    try {
      if (user == null) {
        print('Auth: User signed out, clearing data and navigating to login');
        userController.clearUser();
        _navigateToLogin();
      } else {
        print('Auth: User signed in (${user.uid}), loading user data...');
        await _loadUserAndNavigate(user.uid);
      }
    } catch (e) {
      print('Auth Error in _handleAuthChanged: $e');
      _showError('Authentication error occurred');
    }
  }

  Future<void> _loadUserAndNavigate(String userId) async {
    try {
      await userController.fetchCurrentUser(userId);

      if (userController.currentUser.value != null) {
        print('Auth: User data loaded successfully, navigating to main');
        _navigateToMain();
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      print('Auth Error: Failed to load user data - $e');
      _showError('Failed to load user data. Please try again.');
      await signOut();
    }
  }

  void _navigateToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.currentRoute != AppRoutes.login) {
        Get.offAllNamed(AppRoutes.login);
      }
    });
  }

  void _navigateToMain() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.currentRoute != AppRoutes.main) {
        Get.offAllNamed(AppRoutes.main);
      }
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String userType,
  }) async {
    try {
      isLoading.value = true;
      print('Auth: Starting signup for $email');

      // Create auth user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Auth: User created with ID ${userCredential.user!.uid}');

      // Create user model
      UserModel newUser = UserModel(
        id: userCredential.user!.uid,
        email: email,
        name: name,
        phone: phone,
        userType: userType,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(newUser.toFirestore());

      print('Auth: User data saved to Firestore');

      _showSuccess('Account created successfully!');

      // Auth state listener will handle navigation

    } on FirebaseAuthException catch (e) {
      print('Auth Error: FirebaseAuthException - ${e.code}: ${e.message}');
      String message = _getAuthErrorMessage(e.code);
      _showError(message);
    } catch (e) {
      print('Auth Error: General error - $e');
      _showError('Failed to create account. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      print('Auth: Attempting login for $email');

      // Sign in
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _showSuccess('Welcome back!', duration: 2);

      // Auth state listener will handle navigation

    } on FirebaseAuthException catch (e) {
      print('Auth Error: FirebaseAuthException - ${e.code}: ${e.message}');
      String message = _getAuthErrorMessage(e.code);
      _showError(message);
    } catch (e) {
      print('Auth Error: General login error - $e');
      _showError('Unexpected error during login. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      print('Auth: Signing out...');
      await _auth.signOut();
      // Auth state listener will handle navigation and cleanup
    } catch (e) {
      print('Auth Error: Sign out failed - $e');
      _showError('Failed to sign out');
    }
  }

  Future<void> logout() async {
    await signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showSuccess('Password reset email sent. Check your inbox.');
    } catch (e) {
      print('Auth Error: Password reset failed - $e');
      _showError('Failed to send reset email. Please check the email address.');
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'The password is too weak';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'Invalid email format';
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  void _showSuccess(String message, {int duration = 3}) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      duration: Duration(seconds: duration),
      margin: EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      duration: Duration(seconds: 4),
      margin: EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  // Helper getters
  User? get currentAuthUser => _auth.currentUser;
  bool get isLoggedIn => currentAuthUser != null;
  bool get isInitialized => _isInitialized.value;
}