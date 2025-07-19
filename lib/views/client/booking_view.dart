// views/client/booking_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/listing_model.dart';
import '../../controllers/booking_controller.dart';
import '../../config/theme.dart';
import '../widgets/primary_button.dart';

class BookingView extends StatefulWidget {
  @override
  _BookingViewState createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView> {
  final BookingController bookingController = Get.put(BookingController());
  final ListingModel listing = Get.arguments as ListingModel;

  DateTime? _startDate;
  DateTime? _endDate;
  String _paymentMethod = 'gcash';
  final _deliveryInstructionsController = TextEditingController();

  double get _subtotal {
    if (_startDate == null || _endDate == null) return 0;
    int months = _endDate!.difference(_startDate!).inDays ~/ 30;
    if (months < 1) months = 1;
    return listing.price * months;
  }

  double get _platformFee => _subtotal * 0.09;
  double get _total => _subtotal + _platformFee;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Book Storage'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Listing Summary
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  // Image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(listing.images.first),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          listing.address,
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                listing.size.toUpperCase(),
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              '₱${listing.price.toStringAsFixed(0)}/month',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12),

            // Date Selection
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rental Period',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Start Date
                  _buildDatePicker(
                    label: 'Start Date',
                    date: _startDate,
                    onTap: () => _selectDate(isStart: true),
                  ),

                  SizedBox(height: 12),

                  // End Date
                  _buildDatePicker(
                    label: 'End Date',
                    date: _endDate,
                    onTap: () => _selectDate(isStart: false),
                  ),

                  if (_startDate != null && _endDate != null) ...[
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Minimum rental period is 1 month',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: 12),

            // Payment Method
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Method',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  SizedBox(height: 16),

                  // GCash Option
                  _buildPaymentOption(
                    value: 'gcash',
                    title: 'GCash',
                    subtitle: 'Pay via QR code',
                    icon: Icons.qr_code,
                  ),

                  SizedBox(height: 12),

                  // Bank Transfer Option
                  _buildPaymentOption(
                    value: 'bank',
                    title: 'Bank Transfer',
                    subtitle: 'Direct bank deposit',
                    icon: Icons.account_balance,
                  ),
                ],
              ),
            ),

            SizedBox(height: 12),

            // Delivery Instructions
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery Instructions (Optional)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add pickup/delivery details for GrabExpress or Lalamove',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 16),

                  TextFormField(
                    controller: _deliveryInstructionsController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'e.g., Pickup at 123 Main St, contact 09XX-XXX-XXXX',
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12),

            // Price Breakdown
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Price Breakdown',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  SizedBox(height: 16),

                  _buildPriceRow('Storage Fee', '₱${_subtotal.toStringAsFixed(2)}'),
                  _buildPriceRow('Platform Fee (9%)', '₱${_platformFee.toStringAsFixed(2)}'),

                  Divider(height: 24),

                  _buildPriceRow(
                    'Total',
                    '₱${_total.toStringAsFixed(2)}',
                    isTotal: true,
                  ),
                ],
              ),
            ),

            // Continue Button
            Container(
              padding: EdgeInsets.all(20),
              child: PrimaryButton(
                text: 'Continue to Payment',
                onPressed: (_startDate != null && _endDate != null)
                    ? _proceedToPayment
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.primary),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    date != null
                        ? DateFormat('MMM dd, yyyy').format(date)
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: date != null
                          ? AppColors.primaryText
                          : AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
              color: AppColors.secondaryText,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    bool isSelected = _paymentMethod == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _paymentMethod = value;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.05)
              : AppColors.inputBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.secondaryText,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.primaryText : AppColors.secondaryText,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 20 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? AppColors.primary : AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate({required bool isStart}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? _startDate ?? DateTime.now()),
      firstDate: isStart
          ? DateTime.now()
          : (_startDate ?? DateTime.now()),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.primaryText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // Reset end date if it's before start date
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _proceedToPayment() {
    final bookingData = {
      'listing': listing,
      'startDate': _startDate,
      'endDate': _endDate,
      'totalAmount': _total,
      'platformFee': _platformFee,
      'paymentMethod': _paymentMethod,
      'deliveryInstructions': _deliveryInstructionsController.text,
    };

    Get.toNamed('/client/payment', arguments: bookingData);
  }

  @override
  void dispose() {
    _deliveryInstructionsController.dispose();
    super.dispose();
  }
}

// widgets/primary_button.dart
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}