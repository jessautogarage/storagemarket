// lib/views/shared/profile_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/user_controller.dart';

class ProfileView extends StatelessWidget {
  final AuthController authController = Get.find();
  final UserController userController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
      ),
      body: Obx(() {
        final user = userController.currentUser.value;
        if (user == null) return Container();

        return SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        user.name[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        user.userType.toUpperCase(),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12),

              // Switch Mode
              Container(
                color: Colors.white,
                child: ListTile(
                  leading: Icon(Icons.swap_horiz, color: AppColors.primary),
                  title: Text('Switch to ${user.userType == 'client' ? 'Host' : 'Client'} Mode'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    userController.switchUserType();
                  },
                ),
              ),

              SizedBox(height: 12),

              // Menu Items
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.person_outline,
                      title: 'Edit Profile',
                      onTap: () {
                        // Navigate to edit profile
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.info_outline,
                      title: 'About',
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12),

              // Logout
              Container(
                color: Colors.white,
                child: ListTile(
                  leading: Icon(Icons.logout, color: AppColors.error),
                  title: Text(
                    'Logout',
                    style: TextStyle(color: AppColors.error),
                  ),
                  onTap: () {
                    Get.dialog(
                      AlertDialog(
                        title: Text('Logout'),
                        content: Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.back();
                              authController.logout();
                            },
                            child: Text(
                              'Logout',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryText),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}