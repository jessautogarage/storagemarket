// lib/views/client/payment_confirmation_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../controllers/booking_controller.dart';
import '../widgets/primary_button.dart';

class PaymentConfirmationView extends StatelessWidget {
  final BookingController bookingController = Get.find();
  final Map<String, dynamic> bookingData = Get.arguments;

  @override
  Widget build(BuildContext context) {
    final isGcash = bookingData['paymentMethod'] == 'gcash';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Payment'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Payment Instructions
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(20),
              width: double.infinity,
              child: Column(
                children: [
                  Icon(
                    isGcash ? Icons.qr_code : Icons.account_balance,
                    size: 48,
                    color: AppColors.primary,
                  ).animate()
                      .fadeIn()
                      .scale(),
                  SizedBox(height: 16),
                  Text(
                    isGcash ? 'Scan QR Code' : 'Bank Transfer',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Complete your payment to confirm booking',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: 12),

            // Payment Details
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  if (isGcash) ...[
                    // Mock GCash QR Code
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_2,
                            size: 150,
                            color: AppColors.primaryText,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'GCash QR Placeholder',
                            style: TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ).animate()
                        .fadeIn(delay: 200.ms)
                        .scale(delay: 200.ms),
                    SizedBox(height: 24),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow('Amount',
                            '₱${bookingData['totalAmount'].toStringAsFixed(2)}',
                            isHighlight: true,
                          ),
                          SizedBox(height: 8),
                          _buildInfoRow('Reference',
                            bookingData['bookingId'].substring(0, 8).toUpperCase(),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Bank Transfer Details
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bank Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText,
                            ),
                          ),
                          SizedBox(height: 16),
                          _buildBankDetail('Bank Name', 'BDO Unibank'),
                          _buildBankDetail('Account Name', 'Storage Space Inc.'),
                          _buildBankDetail('Account Number', '1234-5678-9012'),
                          _buildBankDetail('Amount',
                            '₱${bookingData['totalAmount'].toStringAsFixed(2)}',
                            isHighlight: true,
                          ),
                          _buildBankDetail('Reference',
                            bookingData['bookingId'].substring(0, 8).toUpperCase(),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 20),

                  // Instructions
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.warning.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.warning,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Please include the reference number in your payment details',
                            style: TextStyle(
                              color: Colors.orange.shade700, //
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12),

            // Payment Steps
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Steps',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildStep(1, isGcash
                      ? 'Open your GCash app'
                      : 'Open your banking app'),
                  _buildStep(2, isGcash
                      ? 'Scan the QR code above'
                      : 'Transfer to the account above'),
                  _buildStep(3, 'Enter the exact amount'),
                  _buildStep(4, 'Add the reference number'),
                  _buildStep(5, 'Complete the payment'),
                  _buildStep(6, 'Click "I have paid" below'),
                ],
              ),
            ),

            // Action Buttons
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  PrimaryButton(
                    text: 'I have paid',
                    onPressed: () => _confirmPayment(),
                  ),
                  SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: Text(
                      'Pay later',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.secondaryText,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isHighlight ? AppColors.primary : AppColors.primaryText,
            fontSize: isHighlight ? 20 : 16,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBankDetail(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: isHighlight ? AppColors.primary : AppColors.primaryText,
              fontSize: isHighlight ? 20 : 16,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(int number, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmPayment() async {
    await bookingController.markAsPaid(bookingData['bookingId']);

    Get.offAllNamed('/main');
    Get.snackbar(
      'Success',
      'Payment marked as complete. Host will confirm soon.',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
  }
}