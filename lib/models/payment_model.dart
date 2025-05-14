import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String id;
  final String userId;
  final String bookingId;
  final double amount;
  final String status;
  final String paymentMethod;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PaymentModel({
    required this.id,
    required this.userId,
    required this.bookingId,
    required this.amount,
    required this.status,
    required this.paymentMethod,
    required this.createdAt,
    this.updatedAt,
  });

  PaymentModel copyWith({
    String? id,
    String? userId,
    String? bookingId,
    double? amount,
    String? status,
    String? paymentMethod,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookingId: bookingId ?? this.bookingId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'bookingId': bookingId,
      'amount': amount,
      'status': status,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      bookingId: map['bookingId'] as String,
      amount: (map['amount'] as num).toDouble(),
      status: map['status'] as String,
      paymentMethod: map['paymentMethod'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }
}
