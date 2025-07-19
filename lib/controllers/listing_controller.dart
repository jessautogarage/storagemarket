// controllers/listing_controller.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';  // ✅ ADDED - Required for InternetAddress and SocketException
import '../models/listing_model.dart';
import '../services/location_service.dart';
import '../controllers/user_controller.dart';
import '../config/theme.dart';
import 'package:flutter/material.dart';

class ListingController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final LocationService _locationService = LocationService();
  final UserController _userController = Get.find();

  // Observable states
  RxList<ListingModel> listings = <ListingModel>[].obs;
  RxList<ListingModel> filteredListings = <ListingModel>[].obs;
  RxList<ListingModel> myListings = <ListingModel>[].obs;
  RxBool isLoading = false.obs;
  RxString selectedSize = 'all'.obs;
  RxDouble maxPrice = 0.0.obs;
  RxBool hasError = false.obs;
  RxString errorMessage = ''.obs;

  // Pagination
  DocumentSnapshot? _lastDocument;
  final int _pageSize = 20;
  RxBool hasMore = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Delay initial fetch to ensure UI is ready
    Future.delayed(Duration(milliseconds: 500), () {
      fetchListings(showError: false);
    });
  }

  // ✅ IMPROVED - Better connectivity check with timeout
  Future<bool> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  // CREATE - Add new listing
  Future<void> createListing({
    required String title,
    required String description,
    required double price,
    required String size,
    required String address,
    required List<File> images,
    required List<String> features,
  }) async {
    try {
      isLoading.value = true;
      hasError.value = false;

      // ✅ IMPROVED - Use better connectivity check
      if (!await _checkConnectivity()) {
        throw Exception('No internet connection');
      }

      // Get coordinates from address
      final location = await _locationService.getCoordinatesFromAddress(address);

      // Upload images to Firebase Storage
      List<String> imageUrls = [];
      for (int i = 0; i < images.length; i++) {
        final String fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final Reference ref = _storage
            .ref()
            .child('listings')
            .child(_userController.currentUser.value!.id)
            .child(fileName);

        final UploadTask uploadTask = ref.putFile(images[i]);
        final TaskSnapshot taskSnapshot = await uploadTask;
        final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }

      // Create listing document
      final docRef = await _firestore.collection('listings').add({
        'hostId': _userController.currentUser.value!.id,
        'hostName': _userController.currentUser.value!.name,
        'title': title,
        'description': description,
        'images': imageUrls,
        'price': price,
        'size': size,
        'address': address,
        'latitude': location['latitude'],
        'longitude': location['longitude'],
        'isAvailable': true,
        'createdAt': FieldValue.serverTimestamp(),
        'features': features.fold({}, (map, feature) {
          map[feature] = true;
          return map;
        }),
      });

      // Add to local list
      final newListing = ListingModel(
        id: docRef.id,
        hostId: _userController.currentUser.value!.id,
        hostName: _userController.currentUser.value!.name,
        title: title,
        description: description,
        images: imageUrls,
        price: price,
        size: size,
        address: address,
        latitude: location['latitude']!,
        longitude: location['longitude']!,
        createdAt: DateTime.now(),
        features: features.fold({}, (map, feature) {
          map[feature] = true;
          return map;
        }),
      );

      listings.insert(0, newListing);
      myListings.insert(0, newListing);

      Get.snackbar(
        'Success',
        'Listing created successfully!',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

    } catch (e) {
      print('ListingController Error: Failed to create listing - $e');
      String errorMsg = 'Failed to create listing';
      if (e.toString().contains('No internet')) {
        errorMsg = 'No internet connection. Please check your connection and try again.';
      }
      Get.snackbar(
        'Error',
        errorMsg,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // READ - Fetch listings with pagination
  Future<void> fetchListings({bool refresh = false, bool showError = true}) async {
    if (isLoading.value && !refresh) return;

    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // ✅ IMPROVED - Use better connectivity check
      if (!await _checkConnectivity()) {
        throw Exception('No internet connection');
      }

      if (refresh) {
        listings.clear();
        _lastDocument = null;
        hasMore.value = true;
      }

      Query query = _firestore
          .collection('listings')
          .where('isAvailable', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(_pageSize);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final querySnapshot = await query.get();

      if (querySnapshot.docs.isEmpty) {
        hasMore.value = false;
        if (listings.isEmpty) {
          errorMessage.value = 'No listings available yet';
        }
        return;
      }

      _lastDocument = querySnapshot.docs.last;

      final newListings = querySnapshot.docs.map((doc) {
        return ListingModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();

      listings.addAll(newListings);
      filteredListings.value = listings;

      if (querySnapshot.docs.length < _pageSize) {
        hasMore.value = false;
      }

    } catch (e) {
      print('ListingController Error: Failed to fetch listings - $e');
      hasError.value = true;

      if (e.toString().contains('No internet')) {
        errorMessage.value = 'No internet connection';
        if (showError) {
          Get.snackbar(
            'Connection Error',
            'Please check your internet connection',
            backgroundColor: AppColors.error,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 3),
          );
        }
      } else if (e.toString().contains('permission-denied')) {
        errorMessage.value = 'Permission denied. Please login again.';
      } else {
        errorMessage.value = 'Failed to load listings';
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Rest of the methods remain the same...
  // UPDATE, DELETE, FILTER methods as in original code

  // UPDATE - Edit listing
  Future<void> updateListing(String listingId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('listings').doc(listingId).update(updates);

      // Update local list
      final index = listings.indexWhere((l) => l.id == listingId);
      if (index != -1) {
        // Fetch updated listing
        final doc = await _firestore.collection('listings').doc(listingId).get();
        final updatedListing = ListingModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        listings[index] = updatedListing;
      }

      Get.snackbar(
        'Success',
        'Listing updated successfully',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

    } catch (e) {
      print('ListingController Error: Failed to update listing - $e');
      Get.snackbar(
        'Error',
        'Failed to update listing',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // DELETE - Remove listing (soft delete)
  Future<void> deleteListing(String listingId) async {
    try {
      await _firestore.collection('listings').doc(listingId).update({
        'isAvailable': false,
        'deletedAt': FieldValue.serverTimestamp(),
      });

      // Remove from local lists
      listings.removeWhere((l) => l.id == listingId);
      myListings.removeWhere((l) => l.id == listingId);

      Get.snackbar(
        'Success',
        'Listing removed',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('ListingController Error: Failed to delete listing - $e');
      Get.snackbar(
        'Error',
        'Failed to delete listing',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // FILTER - By size
  void filterBySize(String size) {
    selectedSize.value = size;
    if (size == 'all') {
      filteredListings.value = listings;
    } else {
      filteredListings.value = listings.where((l) => l.size == size).toList();
    }
  }

  // FILTER - By price
  void filterByPrice(double maxPrice) {
    this.maxPrice.value = maxPrice;
    filteredListings.value = listings.where((l) => l.price <= maxPrice).toList();
  }

  // FILTER - By location (near me)
  Future<void> filterByLocation() async {
    try {
      isLoading.value = true;

      final Position position = await _locationService.getCurrentLocation();

      // Sort by distance
      List<ListingModel> sortedListings = List.from(listings);
      sortedListings.sort((a, b) {
        double distanceA = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          a.latitude,
          a.longitude,
        );
        double distanceB = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          b.latitude,
          b.longitude,
        );
        return distanceA.compareTo(distanceB);
      });

      // Take nearest 20
      filteredListings.value = sortedListings.take(20).toList();

    } catch (e) {
      print('ListingController Error: Failed to filter by location - $e');
      Get.snackbar(
        'Error',
        'Failed to get location',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // SEARCH - By query
  Future<void> searchListings(String query) async {
    if (query.isEmpty) {
      filteredListings.value = listings;
      return;
    }

    try {
      isLoading.value = true;

      final searchQuery = query.toLowerCase();

      // Search in title, description, and address
      filteredListings.value = listings.where((listing) {
        return listing.title.toLowerCase().contains(searchQuery) ||
            listing.description.toLowerCase().contains(searchQuery) ||
            listing.address.toLowerCase().contains(searchQuery);
      }).toList();

    } finally {
      isLoading.value = false;
    }
  }

  // Get user's own listings
  Future<void> fetchMyListings() async {
    try {
      final querySnapshot = await _firestore
          .collection('listings')
          .where('hostId', isEqualTo: _userController.currentUser.value!.id)
          .orderBy('createdAt', descending: true)
          .get();

      myListings.value = querySnapshot.docs.map((doc) {
        return ListingModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();

    } catch (e) {
      print('ListingController Error: Failed to fetch your listings - $e');
      Get.snackbar(
        'Error',
        'Failed to fetch your listings',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Get listing by ID
  Future<ListingModel?> getListingById(String listingId) async {
    try {
      final doc = await _firestore.collection('listings').doc(listingId).get();

      if (!doc.exists) return null;

      return ListingModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    } catch (e) {
      return null;
    }
  }

  // Real-time listing updates
  void listenToListing(String listingId) {
    _firestore.collection('listings').doc(listingId).snapshots().listen((doc) {
      if (doc.exists) {
        final updatedListing = ListingModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );

        // Update in lists
        final index = listings.indexWhere((l) => l.id == listingId);
        if (index != -1) {
          listings[index] = updatedListing;
        }
      }
    });
  }

  // Retry fetching listings
  Future<void> retryFetch() async {
    await fetchListings(refresh: true);
  }
}