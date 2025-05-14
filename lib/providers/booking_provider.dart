import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../models/payment_model.dart';
import '../services/firestore_service.dart';
import '../services/payment_service.dart';
import '../services/notification_service.dart';

class BookingProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final PaymentService _paymentService = PaymentService();
  final NotificationService _notificationService = NotificationService();

  List<BookingModel> _userBookings = [];
  List<BookingModel> _fieldBookings = [];
  List<DateTime> _availableTimeSlots = [];
  BookingModel? _selectedBooking;
  bool _isLoading = false;
  String? _error;

  List<BookingModel> get userBookings => _userBookings;
  List<BookingModel> get fieldBookings => _fieldBookings;
  List<DateTime> get availableTimeSlots => _availableTimeSlots;
  BookingModel? get selectedBooking => _selectedBooking;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserBookings(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('Loading bookings for userId: $userId');
      _firestoreService.getBookingsByUser(userId).listen((bookings) {
        print('Bookings from Firestore: ${bookings.length}');
        for (var b in bookings) {
          print(
              'Booking: id=[32m${b.id}[0m, userId=[33m${b.userId}[0m, status=[36m${b.status}[0m');
        }
        _userBookings = bookings;
        notifyListeners();
      });

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadFieldBookings(String fieldId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _firestoreService.getBookingsByField(fieldId).listen((bookings) {
        _fieldBookings = bookings;
        notifyListeners();
      });

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadAvailableTimeSlots(
    String fieldId,
    DateTime date,
    TimeOfDay openingTime,
    TimeOfDay closingTime,
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _availableTimeSlots = await _firestoreService.getAvailableTimeSlots(
        fieldId,
        date,
        openingTime,
        closingTime,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> isTimeSlotAvailable(
    String fieldId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      return await _firestoreService.isTimeSlotAvailable(
        fieldId,
        startTime,
        endTime,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> createBooking({
    required String userId,
    required String fieldId,
    required DateTime date,
    required String timeSlot,
    required double amount,
    required String paymentMethod,
    bool withReferee = false,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Verify user authentication
      final user = await _firestoreService.getUser(userId);
      if (user == null) {
        throw Exception('Utilisateur non authentifié');
      }

      // Get field data
      final field = await _firestoreService.getField(fieldId);
      if (field == null) {
        throw Exception('Terrain non trouvé');
      }

      // Parse time slot to get start and end times
      final times = timeSlot.split(' - ');
      final startTime = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(times[0].split(':')[0]),
        int.parse(times[0].split(':')[1]),
      );
      final endTime = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(times[1].split(':')[0]),
        int.parse(times[1].split(':')[1]),
      );

      // Create booking
      final booking = BookingModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        fieldId: fieldId,
        userName: user.name,
        userPhone: user.phone,
        fieldName: field.name,
        startTime: startTime,
        endTime: endTime,
        totalPrice: amount,
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        paymentMethod: paymentMethod,
        withReferee: withReferee,
      );

      // Handle payment based on method
      PaymentModel payment;
      if (paymentMethod == 'flouci') {
        payment = await _paymentService.initiateFlouciPayment(
          userId: userId,
          fieldId: fieldId,
          bookingId: booking.id,
          amount: amount,
        );
      } else if (paymentMethod == 'cash') {
        // For cash payments, create a simple payment record
        payment = PaymentModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userId,
          bookingId: booking.id,
          amount: amount,
          status: 'pending',
          paymentMethod: 'cash',
          createdAt: DateTime.now(),
        );
      } else {
        throw Exception('Mode de paiement non supporté');
      }

      // Update booking with payment ID
      final updatedBooking = booking.copyWith(paymentId: payment.id);

      // Save to Firestore
      await _firestoreService.addBooking(updatedBooking);
      await _firestoreService.addPayment(payment);

      // Add to local state
      _userBookings.add(updatedBooking);

      // Schedule notifications
      await _notificationService.showBookingConfirmation(
        fieldName: field.name,
        date: date,
        timeSlot: timeSlot,
      );

      await _notificationService.scheduleBookingReminder(
        fieldName: field.name,
        date: date,
        timeSlot: timeSlot,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      throw e; // Re-throw the error to be caught by the UI
    }
  }

  Future<void> updateBookingStatus(BookingModel booking, String status) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Update in Firestore first
      await _firestoreService.updateBookingStatus(booking.id, status);

      // Create updated booking with new status
      final updatedBooking = booking.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );

      // Update local state for user bookings
      final userIndex = _userBookings.indexWhere((b) => b.id == booking.id);
      if (userIndex != -1) {
        _userBookings[userIndex] = updatedBooking;
      }

      // Update local state for field bookings
      final fieldIndex = _fieldBookings.indexWhere((b) => b.id == booking.id);
      if (fieldIndex != -1) {
        _fieldBookings[fieldIndex] = updatedBooking;
      }

      // Update selected booking if it's the one being modified
      if (_selectedBooking?.id == booking.id) {
        _selectedBooking = updatedBooking;
      }

      // Send notification based on status
      if (status == 'confirmed') {
        await _notificationService.showBookingConfirmed(
          bookingId: booking.id,
          fieldName: booking.fieldName ?? 'Terrain',
          date: booking.startTime,
          timeSlot:
              '${booking.startTime.hour}:${booking.startTime.minute.toString().padLeft(2, '0')} - ${booking.endTime.hour}:${booking.endTime.minute.toString().padLeft(2, '0')}',
        );
      } else if (status == 'cancelled') {
        await _notificationService.showBookingCancelled(
          bookingId: booking.id,
          fieldName: booking.fieldName ?? 'Terrain',
          date: booking.startTime,
          timeSlot:
              '${booking.startTime.hour}:${booking.startTime.minute.toString().padLeft(2, '0')} - ${booking.endTime.hour}:${booking.endTime.minute.toString().padLeft(2, '0')}',
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSelectedBooking() {
    _selectedBooking = null;
    notifyListeners();
  }

  void clearAll() {
    _userBookings = [];
    _fieldBookings = [];
    _selectedBooking = null;
    _error = null;
    notifyListeners();
  }
}
