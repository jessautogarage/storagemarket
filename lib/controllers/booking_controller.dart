// lib/controllers/booking_controller.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../models/listing_model.dart';
import '../config/theme.dart';
import 'user_controller.dart';

class BookingController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserController _userController = Get.find();

  RxList<BookingModel> myBookings = <BookingModel>[].obs;
  RxList<BookingModel> hostBookings = <BookingModel>[].obs;
  RxBool isLoading = false.obs;

  // ✅ ADDED - Better error handling state
  RxBool hasError = false.obs;
  RxString errorMessage = ''.obs;

  Future<void> createBooking({
    required ListingModel listing,
    required DateTime startDate,
    required DateTime endDate,
    required double totalAmount,
    required double platformFee,
    required String paymentMethod,
    String? deliveryInstructions,
  }) async {
    try {
      isLoading.value = true;
      hasError.value = false;

      // ✅ ADDED - Validation checks
      if (_userController.currentUser.value == null) {
        throw Exception('User not logged in');
      }

      if (startDate.isAfter(endDate)) {
        throw Exception('Start date cannot be after end date');
      }

      if (totalAmount <= 0) {
        throw Exception('Invalid booking amount');
      }

      // ✅ ADDED - Check if listing is still available
      final listingDoc = await _firestore
          .collection('listings')
          .doc(listing.id)
          .get();

      if (!listingDoc.exists || !listingDoc.data()!['isAvailable']) {
        throw Exception('This storage space is no longer available');
      }

      final docRef = await _firestore.collection('bookings').add({
        'listingId': listing.id,
        'clientId': _userController.currentUser.value!.id,
        'hostId': listing.hostId,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'totalAmount': totalAmount,
        'platformFee': platformFee,
        'status': 'pending',
        'paymentMethod': paymentMethod,
        'deliveryInstructions': deliveryInstructions,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // ✅ IMPROVED - Better success feedback
      Get.snackbar(
        'Booking Created',
        'Your booking request has been submitted successfully!',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        icon: Icon(Icons.check_circle, color: Colors.white),
        duration: Duration(seconds: 3),
      );

      Get.offNamed('/client/payment', arguments: {
        'bookingId': docRef.id,
        'listing': listing,
        'totalAmount': totalAmount,
        'paymentMethod': paymentMethod,
      });

    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();

      print('BookingController Error: Failed to create booking - $e');

      // ✅ IMPROVED - More specific error messages
      String userMessage = 'Failed to create booking';
      if (e.toString().contains('not logged in')) {
        userMessage = 'Please log in to make a booking';
      } else if (e.toString().contains('no longer available')) {
        userMessage = 'This storage space is no longer available';
      } else if (e.toString().contains('Start date')) {
        userMessage = 'Please check your selected dates';
      } else if (e.toString().contains('Invalid booking amount')) {
        userMessage = 'Invalid booking amount. Please try again.';
      } else if (e.toString().contains('permission-denied')) {
        userMessage = 'Permission denied. Please log in again.';
      }

      Get.snackbar(
        'Booking Error',
        userMessage,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        icon: Icon(Icons.error, color: Colors.white),
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsPaid(String bookingId, {String? paymentProofUrl}) async {
    try {
      isLoading.value = true;

      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'paid',
        'paidAt': FieldValue.serverTimestamp(),
        if (paymentProofUrl != null) 'paymentProof': paymentProofUrl,
      });

      // ✅ IMPROVED - Better success feedback
      Get.snackbar(
        'Payment Recorded',
        'Your payment has been marked as complete. The host will confirm soon.',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        icon: Icon(Icons.payment, color: Colors.white),
        duration: Duration(seconds: 4),
      );

    } catch (e) {
      print('BookingController Error: Failed to mark as paid - $e');
      Get.snackbar(
        'Payment Error',
        'Failed to update payment status. Please try again.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        icon: Icon(Icons.error, color: Colors.white),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> confirmBooking(String bookingId) async {
    try {
      isLoading.value = true;

      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'confirmed',
        'confirmedAt': FieldValue.serverTimestamp(),
      });

      // ✅ IMPROVED - Better success feedback
      Get.snackbar(
        'Booking Confirmed',
        'The booking has been confirmed successfully!',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        icon: Icon(Icons.check_circle, color: Colors.white),
        duration: Duration(seconds: 3),
      );

      // Refresh the bookings list
      await fetchHostBookings();

    } catch (e) {
      print('BookingController Error: Failed to confirm booking - $e');
      Get.snackbar(
        'Confirmation Error',
        'Failed to confirm booking. Please try again.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        icon: Icon(Icons.error, color: Colors.white),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ ADDED - Reject booking functionality
  Future<void> rejectBooking(String bookingId, {String? reason}) async {
    try {
      isLoading.value = true;

      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
        if (reason != null) 'rejectionReason': reason,
      });

      Get.snackbar(
        'Booking Rejected',
        'The booking has been rejected.',
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        icon: Icon(Icons.cancel, color: Colors.white),
      );

      // Refresh the bookings list
      await fetchHostBookings();

    } catch (e) {
      print('BookingController Error: Failed to reject booking - $e');
      Get.snackbar(
        'Error',
        'Failed to reject booking. Please try again.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMyBookings() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      if (_userController.currentUser.value == null) {
        throw Exception('User not logged in');
      }

      final querySnapshot = await _firestore
          .collection('bookings')
          .where('clientId', isEqualTo: _userController.currentUser.value!.id)
          .orderBy('createdAt', descending: true)
          .get();

      myBookings.value = querySnapshot.docs.map((doc) {
        return BookingModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();

    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load your bookings';
      print('BookingController Error: Failed to fetch bookings - $e');

      Get.snackbar(
        'Error',
        'Failed to load your bookings. Please try again.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchHostBookings() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      if (_userController.currentUser.value == null) {
        throw Exception('User not logged in');
      }

      final querySnapshot = await _firestore
          .collection('bookings')
          .where('hostId', isEqualTo: _userController.currentUser.value!.id)
          .orderBy('createdAt', descending: true)
          .get();

      hostBookings.value = querySnapshot.docs.map((doc) {
        return BookingModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();

    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load booking requests';
      print('BookingController Error: Failed to fetch host bookings - $e');

      Get.snackbar(
        'Error',
        'Failed to load booking requests. Please try again.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ ADDED - Cancel booking functionality
  Future<void> cancelBooking(String bookingId) async {
    try {
      isLoading.value = true;

      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Booking Cancelled',
        'Your booking has been cancelled.',
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      // Refresh bookings
      await fetchMyBookings();

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to cancel booking. Please try again.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ ADDED - Retry functionality
  Future<void> retryFetchBookings() async {
    final user = _userController.currentUser.value;
    if (user?.userType == 'client') {
      await fetchMyBookings();
    } else {
      await fetchHostBookings();
    }
  }
}