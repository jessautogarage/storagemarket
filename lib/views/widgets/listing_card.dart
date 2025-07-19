// lib/views/widgets/listing_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../models/listing_model.dart';

class ListingCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onTap;

  const ListingCard({
    Key? key,
    required this.listing,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: listing.images.isNotEmpty
                        ? listing.images.first
                        : 'https://via.placeholder.com/300',
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.inputBackground,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(AppColors.primary),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.inputBackground,
                      child: Icon(Icons.error, color: AppColors.error),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        listing.size.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  if (!listing.isAvailable)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'BOOKED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: AppColors.secondaryText),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                listing.address,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondaryText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '₱${listing.price.toStringAsFixed(0)}/mo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate()
        .fadeIn(duration: 300.ms)
        .scale(begin: Offset(0.95, 0.95));
  }
}