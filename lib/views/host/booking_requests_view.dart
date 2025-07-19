// lib/views/host/booking_requests_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../controllers/booking_controller.dart';
import '../widgets/booking_status_badge.dart';

class BookingRequestsView extends StatefulWidget {
  @override
  _BookingRequestsViewState createState() => _BookingRequestsViewState();
}

class _BookingRequestsViewState extends State<BookingRequestsView> {
  final BookingController bookingController = Get.find();

  @override
  void initState() {
    super.initState();
    bookingController.fetchHostBookings();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Booking Requests'),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primaryText,
          elevation: 0,
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.secondaryText,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBookingList('paid'),
            _buildBookingList('confirmed'),
            _buildBookingList('completed'),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList(String status) {
    return Obx(() {
      final filteredBookings = bookingController.hostBookings
          .where((b) => b.status == status)
          .toList();

      if (filteredBookings.isEmpty) {
        return Center(
          child: Text(
            'No $status bookings',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 16,
            ),
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(20),
        itemCount: filteredBookings.length,
        itemBuilder: (context, index) {
          final booking = filteredBookings[index];
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
                  Text(
                    'Client: John Doe', // Would fetch from user data
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.primaryText,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(
                          color: AppColors.secondaryText,
                        ),
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
                  if (booking.status == 'paid') ...[
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // Reject booking
                            },
                            child: Text('Reject'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: BorderSide(color: AppColors.error),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              bookingController.confirmBooking(booking.id);
                            },
                            child: Text('Confirm'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      );
    });
  }
}