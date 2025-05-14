import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String userId;
  final String fieldId;
  final String userName;
  final String userPhone;
  final String? fieldName;
  final DateTime startTime;
  final DateTime endTime;
  final double totalPrice;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String paymentMethod;
  final String? paymentId;
  final bool withReferee;

  BookingModel({
    required this.id,
    required this.userId,
    required this.fieldId,
    required this.userName,
    required this.userPhone,
    this.fieldName,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.paymentMethod,
    this.paymentId,
    this.withReferee = false,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    try {
      // Helper function to convert to DateTime
      DateTime convertToDateTime(dynamic value) {
        if (value is Timestamp) {
          return value.toDate();
        } else if (value is String) {
          return DateTime.parse(value);
        }
        throw Exception('Format de date invalide');
      }

      return BookingModel(
        id: map['id'] as String,
        userId: map['userId'] as String,
        fieldId: map['fieldId'] as String,
        userName: map['userName'] as String,
        userPhone: map['userPhone'] as String,
        fieldName: map['fieldName'] as String?,
        startTime: convertToDateTime(map['startTime']),
        endTime: convertToDateTime(map['endTime']),
        totalPrice: (map['totalPrice'] as num).toDouble(),
        status: map['status'] as String,
        createdAt: convertToDateTime(map['createdAt']),
        updatedAt: convertToDateTime(map['updatedAt']),
        paymentMethod: map['paymentMethod'] as String,
        paymentId: map['paymentId'] as String?,
        withReferee: map['withReferee'] as bool? ?? false,
      );
    } catch (e) {
      throw Exception(
          'Erreur lors de la conversion des données de réservation: ${e.toString()}');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'fieldId': fieldId,
      'userName': userName,
      'userPhone': userPhone,
      'fieldName': fieldName,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'paymentMethod': paymentMethod,
      'paymentId': paymentId,
      'withReferee': withReferee,
    };
  }

  BookingModel copyWith({
    String? id,
    String? userId,
    String? fieldId,
    String? userName,
    String? userPhone,
    String? fieldName,
    DateTime? startTime,
    DateTime? endTime,
    double? totalPrice,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? paymentMethod,
    String? paymentId,
    bool? withReferee,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fieldId: fieldId ?? this.fieldId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      fieldName: fieldName ?? this.fieldName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentId: paymentId ?? this.paymentId,
      withReferee: withReferee ?? this.withReferee,
    );
  }
}
