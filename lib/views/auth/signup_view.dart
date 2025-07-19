// lib/views/auth/signup_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../controllers/auth_controller.dart';
import '../widgets/primary_button.dart';

class SignupView extends StatefulWidget {
  @override
  _SignupViewState createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  late final AuthController authController;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _userType = 'client';
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
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Sign up to get started',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.secondaryText,
                  ),
                ),
                SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
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
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone_outlined),
                    hintText: '09XX-XXX-XXXX',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
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
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                Text(
                  'I want to:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryText,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text('Find Storage'),
                        value: 'client',
                        groupValue: _userType,
                        onChanged: (value) {
                          setState(() {
                            _userType = value!;
                          });
                        },
                        activeColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text('List Storage'),
                        value: 'host',
                        groupValue: _userType,
                        onChanged: (value) {
                          setState(() {
                            _userType = value!;
                          });
                        },
                        activeColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32),
                Obx(() => PrimaryButton(
                  text: 'Sign Up',
                  onPressed: authController.isLoading.value ? null : _signUp,
                  isLoading: authController.isLoading.value,
                )),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(color: AppColors.secondaryText),
                    ),
                    TextButton(
                      onPressed: () => Get.offNamed(AppRoutes.login),
                      child: Text(
                        'Login',
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

  void _signUp() {
    if (_formKey.currentState!.validate()) {
      authController.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        userType: _userType,
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}