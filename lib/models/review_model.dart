import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String fieldId;
  final String userId;
  final String userName;
  final String? userImage;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReviewModel({
    required this.id,
    required this.fieldId,
    required this.userId,
    required this.userName,
    this.userImage,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    // Handle timestamp conversion safely
    DateTime getDateTime(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is DateTime) {
        return value;
      } else if (value is String) {
        return DateTime.parse(value);
      }
      throw Exception('Invalid date format');
    }

    return ReviewModel(
      id: map['id'] as String,
      fieldId: map['fieldId'] as String,
      userId: map['userId'] as String,
      userName: map['userName'] as String,
      userImage: map['userImage'] as String?,
      rating: (map['rating'] as num).toDouble(),
      comment: map['comment'] as String,
      createdAt: getDateTime(map['createdAt']),
      updatedAt: getDateTime(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fieldId': fieldId,
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // For backward compatibility
  factory ReviewModel.fromJson(Map<String, dynamic> json) =>
      ReviewModel.fromMap(json);
  Map<String, dynamic> toJson() => toMap();

  ReviewModel copyWith({
    String? id,
    String? fieldId,
    String? userId,
    String? userName,
    String? userImage,
    double? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      fieldId: fieldId ?? this.fieldId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImage: userImage ?? this.userImage,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
