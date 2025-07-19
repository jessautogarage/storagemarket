// lib/views/host/dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../controllers/listing_controller.dart';
import '../../controllers/booking_controller.dart';
import '../widgets/booking_status_badge.dart';

class DashboardView extends StatefulWidget {
  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final ListingController listingController = Get.find();
  final BookingController bookingController = Get.find();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await listingController.fetchMyListings();
    await bookingController.fetchHostBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Income Summary
              Container(
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This Month',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '₱12,500',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildIncomeItem('Active Bookings', '3'),
                        _buildIncomeItem('Total Bookings', '12'),
                        _buildIncomeItem('Avg. Rating', '4.8'),
                      ],
                    ),
                  ],
                ),
              ),

              // Quick Actions
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildQuickAction(
                        icon: Icons.add_business,
                        label: 'Add Listing',
                        onTap: () => Get.toNamed('/host/add-listing'),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickAction(
                        icon: Icons.receipt,
                        label: 'View Bookings',
                        onTap: () {
                          // Navigate to bookings tab
                        },
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Recent Bookings
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Recent Bookings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
              SizedBox(height: 16),

              Obx(() {
                if (bookingController.hostBookings.isEmpty) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    padding: EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'No bookings yet',
                        style: TextStyle(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  itemCount: bookingController.hostBookings.take(3).length,
                  itemBuilder: (context, index) {
                    final booking = bookingController.hostBookings[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(16),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Booking #${booking.id.substring(0, 8).toUpperCase()}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryText,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '₱${booking.totalAmount.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (booking.status == 'paid')
                            ElevatedButton(
                              onPressed: () {
                                bookingController.confirmBooking(booking.id);
                              },
                              child: Text('Confirm'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                            )
                          else
                            BookingStatusBadge(status: booking.status),
                        ],
                      ),
                    );
                  },
                );
              }),

              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncomeItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
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
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: AppColors.primary,
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}