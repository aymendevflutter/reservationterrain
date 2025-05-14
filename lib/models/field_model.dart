import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' show TimeOfDay;

class FieldModel {
  final String id;
  final String ownerId;
  final String name;
  final String description;
  final double pricePerHour;
  final String address;
  final String wilaya;
  final String phone;
  final List<String> images;
  final double rating;
  final int totalRatings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final GeoPoint location;
  final String type;
  final bool hasParking;
  final bool hasLighting;
  final bool hasShowers;
  final bool hasChangingRooms;
  final TimeOfDay openingTime;
  final TimeOfDay closingTime;
  final int maxPlayers;
  final bool hasBuffet;
  final bool hasBalls;
  final bool hasJerseys;
  final bool hasReferee;
  final double refereePrice;
  final Map<String, List<TimeOfDay>> weeklyHours;
  final List<String> closedDays;

  FieldModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.pricePerHour,
    required this.address,
    required this.wilaya,
    required this.phone,
    required this.images,
    required this.rating,
    required this.totalRatings,
    required this.createdAt,
    required this.updatedAt,
    required this.location,
    required this.type,
    required this.openingTime,
    required this.closingTime,
    this.hasParking = false,
    this.hasLighting = false,
    this.hasShowers = false,
    this.hasChangingRooms = false,
    this.maxPlayers = 10,
    this.hasBuffet = false,
    this.hasBalls = false,
    this.hasJerseys = false,
    this.hasReferee = false,
    this.refereePrice = 0.0,
    required this.weeklyHours,
    this.closedDays = const [],
  });

  factory FieldModel.fromMap(Map<String, dynamic> map) {
    final openingTimeParts = (map['openingTime'] as String).split(':');
    final closingTimeParts = (map['closingTime'] as String).split(':');

    // Convert weekly hours from map
    Map<String, List<TimeOfDay>> weeklyHours = {};
    if (map['weeklyHours'] != null) {
      (map['weeklyHours'] as Map<String, dynamic>).forEach((day, hours) {
        if (hours != null) {
          weeklyHours[day] = (hours as List).map((time) {
            final parts = (time as String).split(':');
            return TimeOfDay(
                hour: int.parse(parts[0]), minute: int.parse(parts[1]));
          }).toList();
        }
      });
    }

    // Get closed days
    List<String> closedDays = [];
    if (map['closedDays'] != null) {
      closedDays = List<String>.from(map['closedDays']);
    }

    // Handle date conversion
    DateTime getDateTime(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        return DateTime.parse(value);
      } else if (value is DateTime) {
        return value;
      }
      throw Exception('Invalid date format');
    }

    return FieldModel(
      id: map['id'] as String,
      ownerId: map['ownerId'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      pricePerHour: (map['pricePerHour'] as num).toDouble(),
      address: map['address'] as String,
      wilaya: map['wilaya'] as String,
      phone: map['phone'] as String,
      images: List<String>.from(map['images'] as List),
      rating: (map['rating'] as num).toDouble(),
      totalRatings: map['totalRatings'] as int,
      createdAt: getDateTime(map['createdAt']),
      updatedAt: getDateTime(map['updatedAt']),
      location: map['location'] as GeoPoint,
      type: map['type'] as String,
      openingTime: TimeOfDay(
        hour: int.parse(openingTimeParts[0]),
        minute: int.parse(openingTimeParts[1]),
      ),
      closingTime: TimeOfDay(
        hour: int.parse(closingTimeParts[0]),
        minute: int.parse(closingTimeParts[1]),
      ),
      hasParking: map['hasParking'] as bool? ?? false,
      hasLighting: map['hasLighting'] as bool? ?? false,
      hasShowers: map['hasShowers'] as bool? ?? false,
      hasChangingRooms: map['hasChangingRooms'] as bool? ?? false,
      maxPlayers: map['maxPlayers'] as int? ?? 10,
      hasBuffet: map['hasBuffet'] as bool? ?? false,
      hasBalls: map['hasBalls'] as bool? ?? false,
      hasJerseys: map['hasJerseys'] as bool? ?? false,
      hasReferee: map['hasReferee'] as bool? ?? false,
      refereePrice: (map['refereePrice'] as num?)?.toDouble() ?? 0.0,
      weeklyHours: weeklyHours,
      closedDays: closedDays,
    );
  }

  Map<String, dynamic> toMap() {
    // Convert weekly hours to map
    Map<String, List<String>> weeklyHoursMap = {};
    weeklyHours.forEach((day, hours) {
      if (hours.isNotEmpty) {
        weeklyHoursMap[day] =
            hours.map((time) => '${time.hour}:${time.minute}').toList();
      }
    });

    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'description': description,
      'pricePerHour': pricePerHour,
      'address': address,
      'wilaya': wilaya,
      'phone': phone,
      'images': images,
      'rating': rating,
      'totalRatings': totalRatings,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'location': location,
      'type': type,
      'openingTime': '${openingTime.hour}:${openingTime.minute}',
      'closingTime': '${closingTime.hour}:${closingTime.minute}',
      'hasParking': hasParking,
      'hasLighting': hasLighting,
      'hasShowers': hasShowers,
      'hasChangingRooms': hasChangingRooms,
      'maxPlayers': maxPlayers,
      'hasBuffet': hasBuffet,
      'hasBalls': hasBalls,
      'hasJerseys': hasJerseys,
      'hasReferee': hasReferee,
      'refereePrice': refereePrice,
      'weeklyHours': weeklyHoursMap,
      'closedDays': closedDays,
    };
  }

  FieldModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? description,
    double? pricePerHour,
    String? address,
    String? wilaya,
    String? phone,
    List<String>? images,
    double? rating,
    int? totalRatings,
    DateTime? createdAt,
    DateTime? updatedAt,
    GeoPoint? location,
    String? type,
    TimeOfDay? openingTime,
    TimeOfDay? closingTime,
    bool? hasParking,
    bool? hasLighting,
    bool? hasShowers,
    bool? hasChangingRooms,
    int? maxPlayers,
    bool? hasBuffet,
    bool? hasBalls,
    bool? hasJerseys,
    bool? hasReferee,
    double? refereePrice,
    Map<String, List<TimeOfDay>>? weeklyHours,
    List<String>? closedDays,
  }) {
    return FieldModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      address: address ?? this.address,
      wilaya: wilaya ?? this.wilaya,
      phone: phone ?? this.phone,
      images: images ?? this.images,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      location: location ?? this.location,
      type: type ?? this.type,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      hasParking: hasParking ?? this.hasParking,
      hasLighting: hasLighting ?? this.hasLighting,
      hasShowers: hasShowers ?? this.hasShowers,
      hasChangingRooms: hasChangingRooms ?? this.hasChangingRooms,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      hasBuffet: hasBuffet ?? this.hasBuffet,
      hasBalls: hasBalls ?? this.hasBalls,
      hasJerseys: hasJerseys ?? this.hasJerseys,
      hasReferee: hasReferee ?? this.hasReferee,
      refereePrice: refereePrice ?? this.refereePrice,
      weeklyHours: weeklyHours ?? this.weeklyHours,
      closedDays: closedDays ?? this.closedDays,
    );
  }

  factory FieldModel.fromJson(Map<String, dynamic> json) {
    // Convert weekly hours from json
    Map<String, List<TimeOfDay>> weeklyHours = {};
    if (json['weeklyHours'] != null) {
      (json['weeklyHours'] as Map<String, dynamic>).forEach((day, hours) {
        weeklyHours[day] = (hours as List).map((time) {
          final parts = (time as String).split(':');
          return TimeOfDay(
              hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }).toList();
      });
    }

    // Handle date conversion
    DateTime getDateTime(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        return DateTime.parse(value);
      } else if (value is DateTime) {
        return value;
      }
      throw Exception('Invalid date format');
    }

    return FieldModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String,
      pricePerHour: (json['pricePerHour'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      totalRatings: json['totalRatings'] as int,
      images: List<String>.from(json['images'] as List),
      hasParking: json['hasParking'] as bool,
      hasLighting: json['hasLighting'] as bool,
      hasShowers: json['hasShowers'] as bool,
      hasChangingRooms: json['hasChangingRooms'] as bool,
      ownerId: json['ownerId'] as String,
      wilaya: json['wilaya'] as String,
      location: GeoPoint(
        (json['location'] as Map<String, dynamic>)['latitude'] as double,
        (json['location'] as Map<String, dynamic>)['longitude'] as double,
      ),
      type: json['type'] as String,
      openingTime: TimeOfDay(
        hour: (json['openingTime'] as Map<String, dynamic>)['hour'] as int,
        minute: (json['openingTime'] as Map<String, dynamic>)['minute'] as int,
      ),
      closingTime: TimeOfDay(
        hour: (json['closingTime'] as Map<String, dynamic>)['hour'] as int,
        minute: (json['closingTime'] as Map<String, dynamic>)['minute'] as int,
      ),
      createdAt: getDateTime(json['createdAt']),
      updatedAt: getDateTime(json['updatedAt']),
      weeklyHours: weeklyHours,
      closedDays: List<String>.from(json['closedDays'] ?? []),
    );
  }

  // Helper method to check if a day is closed
  bool isDayClosed(String day) {
    return closedDays.contains(day);
  }

  // Helper method to get hours for a specific day
  List<TimeOfDay> getHoursForDay(String day) {
    if (isDayClosed(day)) {
      return [];
    }
    return weeklyHours[day] ?? [];
  }

  // Helper method to get intervals for a specific day
  List<List<TimeOfDay>> getIntervalsForDay(String day) {
    final hours = getHoursForDay(day);
    List<List<TimeOfDay>> intervals = [];
    for (int i = 0; i + 1 < hours.length; i += 2) {
      intervals.add([hours[i], hours[i + 1]]);
    }
    return intervals;
  }
}
