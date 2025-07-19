// lib/models/booking_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String listingId;
  final String clientId;
  final String hostId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalAmount;
  final double platformFee;
  final String status;
  final String paymentMethod;
  final String? paymentProof;
  final String? deliveryInstructions;
  final DateTime createdAt;
  final DateTime? paidAt;
  final DateTime? confirmedAt;

  BookingModel({
    required this.id,
    required this.listingId,
    required this.clientId,
    required this.hostId,
    required this.startDate,
    required this.endDate,
    required this.totalAmount,
    required this.platformFee,
    this.status = 'pending',
    required this.paymentMethod,
    this.paymentProof,
    this.deliveryInstructions,
    required this.createdAt,
    this.paidAt,
    this.confirmedAt,
  });

  Map<String, dynamic> toFirestore() => {
    'listingId': listingId,
    'clientId': clientId,
    'hostId': hostId,
    'startDate': startDate,
    'endDate': endDate,
    'totalAmount': totalAmount,
    'platformFee': platformFee,
    'status': status,
    'paymentMethod': paymentMethod,
    'paymentProof': paymentProof,
    'deliveryInstructions': deliveryInstructions,
    'createdAt': createdAt,
    'paidAt': paidAt,
    'confirmedAt': confirmedAt,
  };

  factory BookingModel.fromFirestore(Map<String, dynamic> data, String id) {
    return BookingModel(
      id: id,
      listingId: data['listingId'] ?? '',
      clientId: data['clientId'] ?? '',
      hostId: data['hostId'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      platformFee: (data['platformFee'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      paymentMethod: data['paymentMethod'] ?? 'gcash',
      paymentProof: data['paymentProof'],
      deliveryInstructions: data['deliveryInstructions'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      paidAt: data['paidAt'] != null ? (data['paidAt'] as Timestamp).toDate() : null,
      confirmedAt: data['confirmedAt'] != null ? (data['confirmedAt'] as Timestamp).toDate() : null,
    );
  }
}