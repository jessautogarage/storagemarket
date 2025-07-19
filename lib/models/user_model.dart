// models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';



class UserModel {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String userType; // 'client' or 'host'
  final double rating;
  final int totalRatings;
  final DateTime createdAt;
  final String? profileImageUrl;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.userType,
    this.rating = 0.0,
    this.totalRatings = 0,
    required this.createdAt,
    this.profileImageUrl,
  });

  Map<String, dynamic> toFirestore() => {
    'email': email,
    'name': name,
    'phone': phone,
    'userType': userType,
    'rating': rating,
    'totalRatings': totalRatings,
    'createdAt': createdAt,
    'profileImageUrl': profileImageUrl,
  };

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      userType: data['userType'] ?? 'client',
      rating: (data['rating'] is num) ? (data['rating'] as num).toDouble() : 0.0,
      totalRatings: data['totalRatings'] is int ? data['totalRatings'] : 0,
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      profileImageUrl: data['profileImageUrl'] as String?,
    );
  }
}
