// lib/views/auth/login_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../controllers/auth_controller.dart';
import '../widgets/primary_button.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final AuthController authController;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    Get.closeAllSnackbars(); // Clears any lingering snackbars
    authController = Get.find<AuthController>();
    authController.isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                Center(
                  child: Icon(
                    Icons.warehouse_rounded,
                    size: 80,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 40),
                Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Login to continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.secondaryText,
                  ),
                ),
                SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!GetUtils.isEmail(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      _showForgotPasswordDialog();
                    },
                    child: Text('Forgot Password?'),
                  ),
                ),
                SizedBox(height: 32),
                Obx(() => PrimaryButton(
                  text: 'Login',
                  onPressed: authController.isLoading.value ? null : _login,
                  isLoading: authController.isLoading.value,
                )),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: AppColors.secondaryText),
                    ),
                    TextButton(
                      onPressed: () => Get.offNamed(AppRoutes.signup),
                      child: Text(
                        'Sign Up',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      authController.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter your email to receive a password reset link'),
            SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (emailController.text.isNotEmpty &&
                  GetUtils.isEmail(emailController.text)) {
                authController.resetPassword(emailController.text.trim());
                Get.back();
              } else {
                Get.snackbar(
                  'Error',
                  'Please enter a valid email',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}