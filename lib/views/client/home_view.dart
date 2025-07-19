// views/client/home_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/listing_controller.dart';
import '../../controllers/user_controller.dart';
import '../../config/theme.dart';
import '../widgets/listing_card.dart';

class HomeView extends StatelessWidget {
  final ListingController listingController = Get.put(ListingController());
  final UserController userController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header with Search Bar
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting
                    Obx(() => Text(
                      'Hi, ${userController.currentUser.value?.name ?? 'there'}! 👋',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    )),
                    SizedBox(height: 8),
                    Text(
                      'Find your perfect storage space',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    SizedBox(height: 20),

                    // Search Bar
                    GestureDetector(
                      onTap: () => Get.toNamed('/client/search'),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.inputBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: AppColors.secondaryText),
                            SizedBox(width: 12),
                            Text(
                              'Search location or size...',
                              style: TextStyle(
                                color: AppColors.secondaryText,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Quick Filters
            SliverToBoxAdapter(
              child: Container(
                height: 50,
                margin: EdgeInsets.symmetric(vertical: 16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildFilterChip('Near Me', Icons.location_on, () {
                      listingController.filterByLocation();
                    }),
                    _buildFilterChip('Small', Icons.inventory_2, () {
                      listingController.filterBySize('small');
                    }),
                    _buildFilterChip('Medium', Icons.inventory, () {
                      listingController.filterBySize('medium');
                    }),
                    _buildFilterChip('Large', Icons.warehouse, () {
                      listingController.filterBySize('large');
                    }),
                    _buildFilterChip('Under ₱1000', Icons.payments, () {
                      listingController.filterByPrice(1000);
                    }),
                  ],
                ),
              ),
            ),

            // Map View Button
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () => Get.toNamed('/client/map'),
                  child: Container(
                    padding: EdgeInsets.all(16),
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
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.map, color: Colors.white),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'View on Map',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Find storage spaces near you',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Section Title
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text(
                  'Available Spaces',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
            ),

            // Listings Grid
            Obx(() {
              if (listingController.isLoading.value) {
                return SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                );
              }

              // ✅ IMPROVED - Better error handling
              if (listingController.hasError.value) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 80,
                          color: AppColors.secondaryText.withOpacity(0.5),
                        ),
                        SizedBox(height: 16),
                        Text(
                          listingController.errorMessage.value,
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.secondaryText,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => listingController.retryFetch(),
                          icon: Icon(Icons.refresh),
                          label: Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (listingController.listings.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
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
                          'No storage spaces available',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.secondaryText,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Check back later for new listings',
                          style: TextStyle(
                            color: AppColors.secondaryText.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final listing = listingController.listings[index];
                      return ListingCard(
                        listing: listing,
                        onTap: () => Get.toNamed(
                          '/client/listing/${listing.id}',
                          arguments: listing,
                        ),
                      );
                    },
                    childCount: listingController.listings.length,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
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
      ),
    );
  }
}

// ✅ REMOVED - Duplicate AppColors class that was causing conflicts