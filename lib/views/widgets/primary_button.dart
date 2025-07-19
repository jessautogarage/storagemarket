// lib/views/widgets/primary_button.dart
import 'package:flutter/material.dart';
import '../../config/theme.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;

  const PrimaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 56,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          disabledBackgroundColor: (backgroundColor ?? AppColors.primary).withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: isLoading
            ? SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: textColor ?? Colors.white,
            strokeWidth: 2,
          ),
        )
            : Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor ?? Colors.white,
          ),
        ),
      ),
    );
  }
}