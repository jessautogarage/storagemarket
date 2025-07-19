// lib/views/client/map_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../config/theme.dart';
import '../../controllers/listing_controller.dart';
import '../../services/location_service.dart';

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final ListingController listingController = Get.find();
  final LocationService locationService = LocationService();
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  LatLng _currentPosition = LatLng(14.5995, 120.9842); // Default to Manila

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadMarkers();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await locationService.getCurrentLocation();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition, 14),
      );
    } catch (e) {
      // Use default position
    }
  }

  void _loadMarkers() {
    setState(() {
      _markers = listingController.listings.map((listing) {
        return Marker(
          markerId: MarkerId(listing.id),
          position: LatLng(listing.latitude, listing.longitude),
          infoWindow: InfoWindow(
            title: listing.title,
            snippet: '₱${listing.price.toStringAsFixed(0)}/month',
            onTap: () {
              Get.toNamed('/client/listing/${listing.id}', arguments: listing);
            },
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        );
      }).toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Storage Locations'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 12,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),
          Positioned(
            bottom: 80,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              child: Icon(Icons.my_location, color: AppColors.primary),
              onPressed: () {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(_currentPosition, 14),
                );
              },
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${_markers.length} storage spaces available',
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}