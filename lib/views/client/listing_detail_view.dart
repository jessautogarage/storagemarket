// lib/views/client/listing_detail_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../config/theme.dart';
import '../../models/listing_model.dart';
import '../../controllers/listing_controller.dart';
import '../widgets/primary_button.dart';

class ListingDetailView extends StatefulWidget {
  @override
  _ListingDetailViewState createState() => _ListingDetailViewState();
}

class _ListingDetailViewState extends State<ListingDetailView> {
  final ListingController listingController = Get.find<ListingController>();
  ListingModel? listing;
  int _currentImageIndex = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadListing();
  }

  void _loadListing() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Try to get listing from arguments first
      final arguments = Get.arguments;
      if (arguments is ListingModel) {
        setState(() {
          listing = arguments;
          _isLoading = false;
        });
        return;
      }

      // If no arguments, try to get listing ID from parameters
      final listingId = Get.parameters['id'];
      if (listingId == null || listingId.isEmpty) {
        throw Exception('Listing ID not found');
      }

      // Fetch listing by ID
      final fetchedListing = await listingController.getListingById(listingId);
      if (fetchedListing == null) {
        throw Exception('Listing not found');
      }

      setState(() {
        listing = fetchedListing;
        _isLoading = false;
      });

    } catch (e) {
      print('Error loading listing: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.primaryText),
            onPressed: () => Get.back(),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.primaryText),
            onPressed: () => Get.back(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: AppColors.error,
              ),
              SizedBox(height: 16),
              Text(
                'Listing not found',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'This listing may have been removed or is no longer available.',
                style: TextStyle(
                  color: AppColors.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: Text('Go Back'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (listing == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('No listing data')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Gallery
                _buildImageGallery(),

                // Content
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              listing!.title,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryText,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              listing!.size.toUpperCase(),
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),

                      Row(
                        children: [
                          Icon(Icons.location_on,
                            size: 20,
                            color: AppColors.secondaryText,
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              listing!.address,
                              style: TextStyle(
                                color: AppColors.secondaryText,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      // Price
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Monthly Rate',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.primaryText,
                              ),
                            ),
                            Text(
                              '₱${listing!.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12),

                // Features
                if (listing!.features.isNotEmpty) ...[
                  _buildFeaturesSection(),
                  SizedBox(height: 12),
                ],

                // Description
                _buildDescriptionSection(),

                SizedBox(height: 12),

                // Host Info
                _buildHostSection(),

                // Bottom padding for button
                SizedBox(height: 100),
              ],
            ),
          ),

          // Book Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: PrimaryButton(
                text: 'Book Now',
                onPressed: () {
                  Get.toNamed('/client/booking', arguments: listing);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    return Container(
      height: 300,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: listing!.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _openImageGallery(index),
                child: CachedNetworkImage(
                  imageUrl: listing!.images[index],
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
                    child: Center(
                      child: Icon(Icons.error, color: AppColors.error),
                    ),
                  ),
                ),
              );
            },
          ),
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.5),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Get.back(),
              ),
            ),
          ),
          // Image indicators
          if (listing!.images.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  listing!.images.length,
                      (index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Features',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: listing!.features.entries
                .where((e) => e.value == true)
                .map((e) => Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getFeatureIcon(e.key),
                    size: 16,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 4),
                  Text(
                    e.key,
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          SizedBox(height: 12),
          Text(
            listing!.description,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHostSection() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Host',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  listing!.hostName.isNotEmpty
                      ? listing!.hostName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing!.hostName.isNotEmpty ? listing!.hostName : 'Unknown Host',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '4.5',
                          style: TextStyle(
                            color: AppColors.secondaryText,
                          ),
                        ),
                        Text(
                          ' (12 reviews)',
                          style: TextStyle(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getFeatureIcon(String feature) {
    switch (feature) {
      case '24/7 Access':
        return Icons.access_time;
      case 'Climate Control':
        return Icons.ac_unit;
      case 'Security Camera':
        return Icons.videocam;
      case 'Ground Floor':
        return Icons.stairs;
      case 'Electricity':
        return Icons.power;
      case 'Vehicle Access':
        return Icons.directions_car;
      default:
        return Icons.check;
    }
  }

  void _openImageGallery(int initialIndex) {
    Get.to(
          () => Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PhotoViewGallery.builder(
              itemCount: listing!.images.length,
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: CachedNetworkImageProvider(listing!.images[index]),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                );
              },
              pageController: PageController(initialPage: initialIndex),
              scrollPhysics: BouncingScrollPhysics(),
              backgroundDecoration: BoxDecoration(color: Colors.black),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: 30),
                      onPressed: () => Get.back(),
                    ),
                    Text(
                      '${initialIndex + 1} of ${listing!.images.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      transition: Transition.fadeIn,
    );
  }
}