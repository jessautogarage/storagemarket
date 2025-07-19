// lib/services/location_service.dart
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';

class LocationService {
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar('Error', 'Location services are disabled');
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('Error', 'Location permissions are denied');
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar('Error', 'Location permissions are permanently denied');
      return Future.error('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<Map<String, double>> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return {
          'latitude': locations.first.latitude,
          'longitude': locations.first.longitude,
        };
      }
      return {'latitude': 14.5995, 'longitude': 120.9842}; // Default to Manila
    } catch (e) {
      return {'latitude': 14.5995, 'longitude': 120.9842}; // Default to Manila
    }
  }

  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return '${place.street}, ${place.locality}, ${place.administrativeArea}';
      }
      return 'Unknown location';
    } catch (e) {
      return 'Unknown location';
    }
  }
}