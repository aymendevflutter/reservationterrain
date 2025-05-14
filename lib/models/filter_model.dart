import 'package:flutter/material.dart';

class FilterModel {
  final String? wilaya;
  final String? type;
  final double? minPrice;
  final double? maxPrice;
  final bool? hasParking;
  final bool? hasLighting;
  final bool? hasShowers;
  final bool? hasChangingRooms;
  final String? selectedDay;
  final TimeOfDay? selectedTime;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final String? location;
  final double? maxDistance;

  FilterModel({
    this.wilaya,
    this.type,
    this.minPrice,
    this.maxPrice,
    this.hasParking,
    this.hasLighting,
    this.hasShowers,
    this.hasChangingRooms,
    this.selectedDay,
    this.selectedTime,
    this.startTime,
    this.endTime,
    this.location,
    this.maxDistance,
  });

  Map<String, dynamic> toMap() {
    return {
      'wilaya': wilaya,
      'type': type,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'hasParking': hasParking,
      'hasLighting': hasLighting,
      'hasShowers': hasShowers,
      'hasChangingRooms': hasChangingRooms,
      'selectedDay': selectedDay,
      'selectedTime': selectedTime != null
          ? '${selectedTime!.hour}:${selectedTime!.minute}'
          : null,
      'startTime':
          startTime != null ? '${startTime!.hour}:${startTime!.minute}' : null,
      'endTime': endTime != null ? '${endTime!.hour}:${endTime!.minute}' : null,
      'location': location,
      'maxDistance': maxDistance,
    };
  }

  factory FilterModel.fromMap(Map<String, dynamic> map) {
    TimeOfDay? selectedTime;
    if (map['selectedTime'] != null) {
      final parts = (map['selectedTime'] as String).split(':');
      selectedTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
    TimeOfDay? startTime;
    if (map['startTime'] != null) {
      final parts = (map['startTime'] as String).split(':');
      startTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
    TimeOfDay? endTime;
    if (map['endTime'] != null) {
      final parts = (map['endTime'] as String).split(':');
      endTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
    return FilterModel(
      wilaya: map['wilaya'] as String?,
      type: map['type'] as String?,
      minPrice: map['minPrice'] as double?,
      maxPrice: map['maxPrice'] as double?,
      hasParking: map['hasParking'] as bool?,
      hasLighting: map['hasLighting'] as bool?,
      hasShowers: map['hasShowers'] as bool?,
      hasChangingRooms: map['hasChangingRooms'] as bool?,
      selectedDay: map['selectedDay'] as String?,
      selectedTime: selectedTime,
      startTime: startTime,
      endTime: endTime,
      location: map['location'] as String?,
      maxDistance: map['maxDistance'] as double?,
    );
  }

  FilterModel copyWith({
    String? wilaya,
    String? type,
    double? minPrice,
    double? maxPrice,
    bool? hasParking,
    bool? hasLighting,
    bool? hasShowers,
    bool? hasChangingRooms,
    String? selectedDay,
    TimeOfDay? selectedTime,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? location,
    double? maxDistance,
  }) {
    return FilterModel(
      wilaya: wilaya ?? this.wilaya,
      type: type ?? this.type,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      hasParking: hasParking ?? this.hasParking,
      hasLighting: hasLighting ?? this.hasLighting,
      hasShowers: hasShowers ?? this.hasShowers,
      hasChangingRooms: hasChangingRooms ?? this.hasChangingRooms,
      selectedDay: selectedDay ?? this.selectedDay,
      selectedTime: selectedTime ?? this.selectedTime,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      maxDistance: maxDistance ?? this.maxDistance,
    );
  }
}
