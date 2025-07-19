// lib/views/host/manage_listings_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../controllers/listing_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';


class ManageListingsView extends StatefulWidget {
  @override
  _ManageListingsViewState createState() => _ManageListingsViewState();
}

class _ManageListingsViewState extends State<ManageListingsView> {
  final ListingController listingController = Get.find();

  @override
  void initState() {
    super.initState();
    listingController.fetchMyListings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Listings'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Get.toNamed('/host/add-listing'),
          ),
        ],
      ),
      body: Obx(() {
        if (listingController.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          );
        }

        if (listingController.myListings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 80,
                  color: AppColors.secondaryText.withOpacity(0.5),
                ),
                SizedBox(height: 16),
                Text(
                  'No listings yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.secondaryText,
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed('/host/add-listing'),
                  icon: Icon(Icons.add),
                  label: Text('Add First Listing'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(20),
          itemCount: listingController.myListings.length,
          itemBuilder: (context, index) {
            final listing = listingController.myListings[index];
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
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: listing.images.first,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 16),
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
                              Text(
                                '₱${listing.price.toStringAsFixed(0)}/mo',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(width: 16),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: listing.isAvailable
                                      ? AppColors.success.withOpacity(0.1)
                                      : AppColors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  listing.isAvailable ? 'Available' : 'Booked',
                                  style: TextStyle(
                                    color: listing.isAvailable
                                        ? AppColors.success
                                        : AppColors.error,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton(
                      icon: Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'delete') {
                          _confirmDelete(listing.id);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _confirmDelete(String listingId) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Listing'),
        content: Text('Are you sure you want to delete this listing?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              listingController.deleteListing(listingId);
              Get.back();
            },
            child: Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}