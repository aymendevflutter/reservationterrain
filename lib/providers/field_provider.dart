import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/field_model.dart';
import '../models/filter_model.dart';
import '../services/firestore_service.dart';
import 'dart:io';
import 'package:latlong2/latlong.dart';

class FieldProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  List<FieldModel> _fields = [];
  List<FieldModel> _filteredFields = [];
  List<FieldModel> _ownerFields = [];
  FieldModel? _selectedField;
  FilterModel? _currentFilters;
  bool _isLoading = false;
  String? _error;
  String? _searchQuery;

  FieldProvider({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  List<FieldModel> get fields => _filteredFields;
  List<FieldModel> get ownerFields => _ownerFields;
  FieldModel? get selectedField => _selectedField;
  bool get isLoading => _isLoading;
  String? get error => _error;
  FilterModel? get currentFilters => _currentFilters;
  String? get searchQuery => _searchQuery;

  set searchQuery(String? value) {
    _searchQuery = value;
    _filterFields();
  }

  Future<void> loadFields() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final fieldsStream = await _firestoreService.getFields();
      fieldsStream.listen(
        (fields) {
          _fields = fields;
          _filterFields();
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          _error = error.toString();
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadOwnerFields(String ownerId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _ownerFields = await _firestoreService.getFieldsByOwner(ownerId).first;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectField(String fieldId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _selectedField = await _firestoreService.getField(fieldId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void applyFilters(FilterModel filters) {
    _currentFilters = filters;
    _filterFields();
  }

  void _filterFields() {
    if (_currentFilters == null &&
        (_searchQuery == null || _searchQuery!.isEmpty)) {
      _filteredFields = List.from(_fields);
      notifyListeners();
      return;
    }

    _filteredFields = _fields.where((field) {
      // Search filter
      if (_searchQuery != null && _searchQuery!.isNotEmpty) {
        final query = _searchQuery!.toLowerCase();
        if (!field.name.toLowerCase().contains(query)) {
          return false;
        }
      }
      // Wilaya filter
      if (_currentFilters?.wilaya != null &&
          field.wilaya != _currentFilters!.wilaya) {
        return false;
      }
      // Type filter
      if (_currentFilters?.type != null &&
          field.type != _currentFilters!.type) {
        return false;
      }
      // Price range filter
      if (_currentFilters?.minPrice != null &&
          field.pricePerHour < _currentFilters!.minPrice!) {
        return false;
      }
      if (_currentFilters?.maxPrice != null &&
          field.pricePerHour > _currentFilters!.maxPrice!) {
        return false;
      }
      // Equipment filters
      if (_currentFilters?.hasParking == true && !field.hasParking) {
        return false;
      }
      if (_currentFilters?.hasLighting == true && !field.hasLighting) {
        return false;
      }
      if (_currentFilters?.hasShowers == true && !field.hasShowers) {
        return false;
      }
      if (_currentFilters?.hasChangingRooms == true &&
          !field.hasChangingRooms) {
        return false;
      }
      // Time and day filter
      if (_currentFilters?.selectedDay != null) {
        final selectedDay = _currentFilters!.selectedDay!;
        // Exclude if the field is closed on this day
        if (field.closedDays.contains(selectedDay)) {
          return false;
        }
        // Filter by interval if set
        if (_currentFilters?.startTime != null &&
            _currentFilters?.endTime != null) {
          final filterStart = _currentFilters!.startTime!;
          final filterEnd = _currentFilters!.endTime!;
          final filterStartMinutes = filterStart.hour * 60 + filterStart.minute;
          final filterEndMinutes = filterEnd.hour * 60 + filterEnd.minute;
          // Check custom intervals if present
          final intervals = field.getIntervalsForDay(selectedDay);
          bool intervalOk = false;
          if (intervals.isNotEmpty) {
            for (final interval in intervals) {
              final intervalStart = interval[0];
              final intervalEnd = interval[1];
              final intervalStartMinutes =
                  intervalStart.hour * 60 + intervalStart.minute;
              final intervalEndMinutes =
                  intervalEnd.hour * 60 + intervalEnd.minute;
              if (filterStartMinutes >= intervalStartMinutes &&
                  filterEndMinutes <= intervalEndMinutes) {
                intervalOk = true;
                break;
              }
            }
            if (!intervalOk) return false;
          } else {
            // Use default opening/closing
            final openingMinutes =
                field.openingTime.hour * 60 + field.openingTime.minute;
            final closingMinutes =
                field.closingTime.hour * 60 + field.closingTime.minute;
            if (filterStartMinutes < openingMinutes ||
                filterEndMinutes > closingMinutes) {
              return false;
            }
          }
        }
      }
      return true;
    }).toList();
    notifyListeners();
  }

  void clearFilters() {
    _currentFilters = null;
    _filteredFields = List.from(_fields);
    notifyListeners();
  }

  Future<void> addField({
    required String name,
    required String description,
    required String ownerId,
    required double price,
    required List<String> imagePaths,
    required Map<String, List<String>> availableHours,
    required String address,
    required String phone,
    required GeoPoint location,
    required String wilaya,
    required TimeOfDay openingTime,
    required TimeOfDay closingTime,
    bool hasReferee = false,
    double refereePrice = 0.0,
    List<String> closedDays = const [],
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Convert available hours to TimeOfDay
      Map<String, List<TimeOfDay>> weeklyHours = {};
      availableHours.forEach((day, hours) {
        if (hours.isNotEmpty) {
          weeklyHours[day] = hours.map((time) {
            final parts = time.split(':');
            return TimeOfDay(
              hour: int.parse(parts[0]),
              minute: int.parse(parts[1]),
            );
          }).toList();
        }
      });

      final field = FieldModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
        ownerId: ownerId,
        pricePerHour: price,
        address: address,
        wilaya: wilaya,
        phone: phone,
        images: imagePaths,
        rating: 0,
        totalRatings: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        location: location,
        type: 'Football',
        openingTime: openingTime,
        closingTime: closingTime,
        hasReferee: hasReferee,
        refereePrice: refereePrice,
        weeklyHours: weeklyHours,
        closedDays: closedDays,
      );

      await _firestoreService.addField(field);
      await loadFields();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateField(FieldModel field) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestoreService.updateField(field);
      await loadFields();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteField(String fieldId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestoreService.deleteField(fieldId);
      await loadFields();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSelectedField() {
    _selectedField = null;
    notifyListeners();
  }
}
