// lib/models/listing_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ListingModel {
  final String id;
  final String hostId;
  final String hostName;
  final String title;
  final String description;
  final List<String> images;
  final double price;
  final String size;
  final String address;
  final double latitude;
  final double longitude;
  final bool isAvailable;
  final DateTime createdAt;
  final Map<String, dynamic> features;

  ListingModel({
    required this.id,
    required this.hostId,
    required this.hostName,
    required this.title,
    required this.description,
    required this.images,
    required this.price,
    required this.size,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.isAvailable = true,
    required this.createdAt,
    this.features = const {},
  });

  Map<String, dynamic> toFirestore() => {
    'hostId': hostId,
    'hostName': hostName,
    'title': title,
    'description': description,
    'images': images,
    'price': price,
    'size': size,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'isAvailable': isAvailable,
    'createdAt': createdAt,
    'features': features,
  };

  factory ListingModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ListingModel(
      id: id,
      hostId: data['hostId'] ?? '',
      hostName: data['hostName'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      price: (data['price'] ?? 0).toDouble(),
      size: data['size'] ?? 'medium',
      address: data['address'] ?? '',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      isAvailable: data['isAvailable'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      features: Map<String, dynamic>.from(data['features'] ?? {}),
    );
  }
}