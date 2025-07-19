// lib/controllers/user_controller.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  RxBool isLoading = false.obs;

  Future<void> fetchCurrentUser(String userId) async {
    try {
      isLoading.value = true;

      DocumentSnapshot doc =
      await _firestore.collection('users').doc(userId).get();

      if (!doc.exists || doc.data() == null) {
        print('UserController: No user found or access denied');
        throw Exception('No user found');
      }

      final data = doc.data() as Map<String, dynamic>;

      currentUser.value = UserModel.fromFirestore(data, doc.id);
    } catch (e) {
      print('UserController error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> updateProfile({
    required String name,
    required String phone,
    String? profileImageUrl,
  }) async {
    try {
      if (currentUser.value == null) return;

      await _firestore
          .collection('users')
          .doc(currentUser.value!.id)
          .update({
        'name': name,
        'phone': phone,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      });

      // Update local user
      currentUser.value = UserModel(
        id: currentUser.value!.id,
        email: currentUser.value!.email,
        name: name,
        phone: phone,
        userType: currentUser.value!.userType,
        rating: currentUser.value!.rating,
        totalRatings: currentUser.value!.totalRatings,
        createdAt: currentUser.value!.createdAt,
        profileImageUrl: profileImageUrl ?? currentUser.value!.profileImageUrl,
      );

      Get.snackbar('Success', 'Profile updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile');
    }
  }

  Future<void> switchUserType() async {
    try {
      if (currentUser.value == null) return;

      String newType = currentUser.value!.userType == 'client' ? 'host' : 'client';

      await _firestore
          .collection('users')
          .doc(currentUser.value!.id)
          .update({'userType': newType});

      currentUser.value = UserModel(
        id: currentUser.value!.id,
        email: currentUser.value!.email,
        name: currentUser.value!.name,
        phone: currentUser.value!.phone,
        userType: newType,
        rating: currentUser.value!.rating,
        totalRatings: currentUser.value!.totalRatings,
        createdAt: currentUser.value!.createdAt,
        profileImageUrl: currentUser.value!.profileImageUrl,
      );

      Get.snackbar('Success', 'Switched to ${newType} mode');
    } catch (e) {
      Get.snackbar('Error', 'Failed to switch user type');
    }
  }

  void clearUser() {
    currentUser.value = null;
  }
}