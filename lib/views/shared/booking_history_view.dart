// lib/views/shared/booking_history_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../controllers/booking_controller.dart';
import '../../controllers/user_controller.dart';
import '../../models/booking_model.dart';
import '../widgets/booking_status_badge.dart';

class BookingHistoryView extends StatefulWidget {
  @override
  _BookingHistoryViewState createState() => _BookingHistoryViewState();
}

class _BookingHistoryViewState extends State<BookingHistoryView> {
  final BookingController bookingController = Get.find();
  final UserController userController = Get.find();

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final user = userController.currentUser.value;
    if (user?.userType == 'client') {
      await bookingController.fetchMyBookings();
    } else {
      await bookingController.fetchHostBookings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Bookings'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
      ),
      body: Obx(() {
        final user = userController.currentUser.value;
        final bookings = user?.userType == 'client'
            ? bookingController.myBookings
            : bookingController.hostBookings;

        if (bookingController.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          );
        }

        if (bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 80,
                  color: AppColors.secondaryText.withOpacity(0.5),
                ),
                SizedBox(height: 16),
                Text(
                  'No bookings yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.secondaryText,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  user?.userType == 'client'
                      ? 'Start browsing storage spaces'
                      : 'Your bookings will appear here',
                  style: TextStyle(
                    color: AppColors.secondaryText.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadBookings,
          color: AppColors.primary,
          child: ListView.builder(
            padding: EdgeInsets.all(20),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return _buildBookingCard(booking);
            },
          ),
        );
      }),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booking #${booking.id.substring(0, 8).toUpperCase()}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
                BookingStatusBadge(status: booking.status),
              ],
            ),
            SizedBox(height: 12),

            // Date Range
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: AppColors.secondaryText),
                SizedBox(width: 8),
                Text(
                  '${DateFormat('MMM dd').format(booking.startDate)} - ${DateFormat('MMM dd, yyyy').format(booking.endDate)}',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            SizedBox(height: 8),

            // Payment Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.payment, size: 16, color: AppColors.secondaryText),
                    SizedBox(width: 8),
                    Text(
                      booking.paymentMethod.toUpperCase(),
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Text(
                  '₱${booking.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 18,
                  ),
                ),
              ],
            ),

            // Actions for pending bookings
            if (booking.status == 'pending' && userController.currentUser.value?.userType == 'client') ...[
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.toNamed(AppRoutes.paymentConfirmation, arguments: {
                      'bookingId': booking.id,
                      'totalAmount': booking.totalAmount,
                      'paymentMethod': booking.paymentMethod,
                    });
                  },
                  child: Text('Complete Payment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}