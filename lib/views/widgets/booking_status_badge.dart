// lib/views/widgets/booking_status_badge.dart
import 'package:flutter/material.dart';
import '../../config/theme.dart';

class BookingStatusBadge extends StatelessWidget {
  final String status;

  const BookingStatusBadge({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: config['color'].withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config['icon'],
            size: 16,
            color: config['color'],
          ),
          SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: config['color'],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig() {
    switch (status.toLowerCase()) {
      case 'pending':
        return {'color': Colors.orange, 'icon': Icons.schedule};
      case 'paid':
        return {'color': Colors.blue, 'icon': Icons.payment};
      case 'confirmed':
        return {'color': AppColors.success, 'icon': Icons.check_circle};
      case 'completed':
        return {'color': Colors.grey, 'icon': Icons.done_all};
      case 'cancelled':
        return {'color': AppColors.error, 'icon': Icons.cancel};
      default:
        return {'color': Colors.grey, 'icon': Icons.info};
    }
  }
}