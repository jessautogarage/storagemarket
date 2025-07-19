// lib/views/client/search_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';  // ✅ ADDED - Required for Timer
import '../../config/theme.dart';
import '../../controllers/listing_controller.dart';
import '../widgets/listing_card.dart';

class SearchView extends StatefulWidget {
  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final ListingController listingController = Get.find();
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  // ✅ ADDED - Debouncing for better performance
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  // ✅ ADDED - Debounced search function
  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 500), () {
      listingController.searchListings(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Search location, size, or features...',
            border: InputBorder.none,
            filled: false,
          ),
          onChanged: _onSearchChanged, // ✅ IMPROVED - Using debounced search
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                listingController.searchListings('');
                _focusNode.requestFocus();
              },
            ),
          // ✅ ADDED - Filter button
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ ADDED - Quick search suggestions
          if (_searchController.text.isEmpty) _buildQuickSearchSuggestions(),

          // ✅ ADDED - Active filters display
          Obx(() {
            if (listingController.selectedSize.value != 'all' ||
                listingController.maxPrice.value > 0) {
              return _buildActiveFilters();
            }
            return SizedBox.shrink();
          }),

          // Search results
          Expanded(
            child: Obx(() {
              if (listingController.isLoading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Searching...',
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final searchResults = _searchController.text.isEmpty
                  ? listingController.listings
                  : listingController.filteredListings;

              if (searchResults.isEmpty && _searchController.text.isNotEmpty) {
                return _buildNoResultsFound();
              }

              if (searchResults.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search,
                        size: 80,
                        color: AppColors.secondaryText.withOpacity(0.5),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Start typing to search',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Find storage by location, size, or features',
                        style: TextStyle(
                          color: AppColors.secondaryText.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: EdgeInsets.all(20),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final listing = searchResults[index];
                  return ListingCard(
                    listing: listing,
                    onTap: () => Get.toNamed(
                      '/client/listing/${listing.id}',
                      arguments: listing,
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // ✅ ADDED - Quick search suggestions
  Widget _buildQuickSearchSuggestions() {
    final suggestions = [
      'Near me',
      'Small spaces',
      'Climate controlled',
      'Manila',
      'Makati',
      'BGC',
      'Under ₱1000',
    ];

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Search',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((suggestion) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = suggestion;
                  _onSearchChanged(suggestion);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    suggestion,
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ✅ ADDED - Active filters display
  Widget _buildActiveFilters() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Text(
            'Filters:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.secondaryText,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (listingController.selectedSize.value != 'all')
                    _buildFilterChip(
                      listingController.selectedSize.value.toUpperCase(),
                          () => listingController.filterBySize('all'),
                    ),
                  if (listingController.maxPrice.value > 0)
                    _buildFilterChip(
                      'Under ₱${listingController.maxPrice.value.toInt()}',
                          () => listingController.filterByPrice(0),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 16,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ ADDED - No results found widget
  Widget _buildNoResultsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: AppColors.secondaryText.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.secondaryText,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try different keywords or check filters',
            style: TextStyle(
              color: AppColors.secondaryText.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {
                  _searchController.clear();
                  listingController.searchListings('');
                  listingController.filterBySize('all');
                  listingController.filterByPrice(0);
                },
                child: Text('Clear All'),
              ),
              SizedBox(width: 12),
              ElevatedButton(
                onPressed: _showFilterBottomSheet,
                child: Text('Adjust Filters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ ADDED - Filter bottom sheet
  void _showFilterBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    listingController.filterBySize('all');
                    listingController.filterByPrice(0);
                    Get.back();
                  },
                  child: Text('Clear All'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Size',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
            SizedBox(height: 12),
            Obx(() => Wrap(
              spacing: 8,
              children: ['all', 'small', 'medium', 'large'].map((size) {
                bool isSelected = listingController.selectedSize.value == size;
                return FilterChip(
                  label: Text(size == 'all' ? 'Any Size' : size.toUpperCase()),
                  selected: isSelected,
                  onSelected: (selected) {
                    listingController.filterBySize(size);
                  },
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  checkmarkColor: AppColors.primary,
                );
              }).toList(),
            )),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('Cancel'),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: Text('Apply Filters'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel(); // ✅ ADDED - Cancel timer
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}