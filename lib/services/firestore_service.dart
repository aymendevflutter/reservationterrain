import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import '../models/field_model.dart';
import '../models/booking_model.dart';
import '../models/payment_model.dart';
import '../models/user_model.dart';
import '../models/review_model.dart';
import '../core/constants/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fields Collection
  Stream<List<FieldModel>> getFields() {
    return _firestore
        .collection(AppConstants.fieldsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => FieldModel.fromMap({'id': doc.id, ...doc.data()}),
              )
              .toList(),
        );
  }

  Stream<List<FieldModel>> getFieldsByOwner(String ownerId) {
    final query =
        _firestore.collection('fields').where('ownerId', isEqualTo: ownerId);

    // Log the Firebase query link
    print('\n=== Lien de la requête Firebase ===');
    print('Collection: fields');
    print('Requête: where("ownerId", isEqualTo: "$ownerId")');
    print(
        'URL: https://console.firebase.google.com/project/YOUR_PROJECT_ID/firestore/data/fields');
    print('========================\n');

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => FieldModel.fromMap({'id': doc.id, ...doc.data()}),
          )
          .toList();
    });
  }

  Future<FieldModel> getField(String fieldId) async {
    final doc = await _firestore.collection('fields').doc(fieldId).get();
    if (!doc.exists) {
      throw Exception('Terrain non trouvé');
    }
    return FieldModel.fromMap({'id': doc.id, ...doc.data()!});
  }

  Future<void> addField(FieldModel field) async {
    try {
      final docRef = _firestore.collection('fields').doc();
      final fieldWithId = field.copyWith(id: docRef.id);
      await docRef.set(fieldWithId.toMap());
    } catch (e) {
      throw Exception('Failed to add field: $e');
    }
  }

  Future<void> updateField(FieldModel field) async {
    await _firestore.collection('fields').doc(field.id).update(field.toMap());
  }

  Future<void> deleteField(String fieldId) async {
    await _firestore.collection('fields').doc(fieldId).delete();
  }

  // Bookings Collection
  Stream<List<BookingModel>> getBookingsByUser(String userId) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => BookingModel.fromMap({'id': doc.id, ...doc.data()}),
          )
          .toList();
    });
  }

  Stream<List<BookingModel>> getBookingsByField(String fieldId) {
    try {
      final query = _firestore
          .collection('bookings')
          .where('fieldId', isEqualTo: fieldId)
          .orderBy('startTime', descending: true);

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map(
              (doc) => BookingModel.fromMap({'id': doc.id, ...doc.data()}),
            )
            .toList();
      }).handleError((error) {
        if (error.toString().contains('failed-precondition')) {
          print(
              '\nErreur: [cloud_firestore/failed-precondition] The query requires an index. You can create it here: ');
          print(
              'https://console.firebase.google.com/v1/r/project/reservationterrain-f56d4/firestore/indexes?create_composite=CIlwcm9qZWN0cy9yZXNlcnZhdGlvbnRlcnJhaW4tZjU2ZDQvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL2Jvb2tpbmdzL2luZGV4ZXMvXyILCgdmaWVsZElkEAEiCwoJc3RhcnRUaW1lEAIaDAoIX19uYW1lX18QAg\n');
        }
        throw error;
      });
    } catch (e) {
      print('Error in getBookingsByField: $e');
      rethrow;
    }
  }

  Stream<List<BookingModel>> getBookingsByOwner(String ownerId) {
    try {
      // Récupérer d'abord tous les terrains appartenant à ce propriétaire
      return _firestore
          .collection('fields')
          .where('ownerId', isEqualTo: ownerId)
          .snapshots()
          .asyncMap((fieldsSnapshot) async {
        if (fieldsSnapshot.docs.isEmpty) {
          return <BookingModel>[];
        }

        // Récupérer tous les IDs des terrains
        final fieldIds = fieldsSnapshot.docs.map((doc) => doc.id).toList();

        // Ensuite récupérer toutes les réservations pour ces terrains
        final bookingsSnapshot = await _firestore
            .collection('bookings')
            .where('fieldId', whereIn: fieldIds)
            .orderBy('startTime', descending: true)
            .get();

        return bookingsSnapshot.docs.map((doc) {
          final data = doc.data();
          // Vérifier que les timestamps sont correctement convertis
          if (data['startTime'] is! Timestamp) {
            throw Exception('Le format de la date de début est invalide');
          }
          if (data['endTime'] is! Timestamp) {
            throw Exception('Le format de la date de fin est invalide');
          }
          if (data['createdAt'] is! Timestamp) {
            throw Exception('Le format de la date de création est invalide');
          }
          if (data['updatedAt'] is! Timestamp) {
            throw Exception('Le format de la date de mise à jour est invalide');
          }

          return BookingModel.fromMap({'id': doc.id, ...data});
        }).toList();
      }).handleError((error) {
        print('Erreur dans getBookingsByOwner: $error');
        if (error.toString().contains('failed-precondition')) {
          throw Exception(
              'Une erreur est survenue lors de la récupération des réservations. Veuillez réessayer.');
        }
        throw Exception(
            'Une erreur est survenue lors de la récupération des réservations: ${error.toString()}');
      });
    } catch (e) {
      print('Erreur dans getBookingsByOwner: $e');
      throw Exception(
          'Une erreur est survenue lors de la récupération des réservations: ${e.toString()}');
    }
  }

  Future<BookingModel> getBooking(String bookingId) async {
    final doc = await _firestore.collection('bookings').doc(bookingId).get();
    if (!doc.exists) {
      throw Exception('Réservation non trouvée');
    }
    return BookingModel.fromMap({'id': doc.id, ...doc.data()!});
  }

  Future<void> addBooking(BookingModel booking) async {
    try {
      await _firestore
          .collection('bookings')
          .doc(booking.id)
          .set(booking.toMap());
    } catch (e) {
      throw Exception('Error adding booking: $e');
    }
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': status,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> deleteBooking(String bookingId) async {
    await _firestore.collection('bookings').doc(bookingId).delete();
  }

  Future<void> updateBooking(BookingModel booking) async {
    await _firestore
        .collection('bookings')
        .doc(booking.id)
        .update(booking.toMap());
  }

  // Payments Collection
  Stream<List<PaymentModel>> getPaymentsByUser(String userId) {
    return _firestore
        .collection(AppConstants.paymentsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => PaymentModel.fromMap({'id': doc.id, ...doc.data()}),
              )
              .toList(),
        );
  }

  Future<PaymentModel> getPayment(String paymentId) async {
    final doc = await _firestore.collection('payments').doc(paymentId).get();
    if (!doc.exists) {
      throw Exception('Payment not found');
    }
    return PaymentModel.fromMap({'id': doc.id, ...doc.data()!});
  }

  Future<PaymentModel> createPayment(PaymentModel payment) async {
    final doc = await _firestore.collection('payments').add(payment.toMap());
    return payment.copyWith(id: doc.id);
  }

  Future<void> updatePayment(PaymentModel payment) async {
    await _firestore
        .collection('payments')
        .doc(payment.id)
        .update(payment.toMap());
  }

  Future<void> addPayment(PaymentModel payment) async {
    final docRef = _firestore.collection('payments').doc();
    await docRef.set({...payment.toMap(), 'id': docRef.id});
  }

  // Users
  Stream<List<UserModel>> getUsers() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => UserModel.fromMap({'id': doc.id, ...doc.data()}),
              )
              .toList(),
        );
  }

  Future<UserModel> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) {
      throw Exception('User not found');
    }
    return UserModel.fromMap({'id': doc.id, ...doc.data()!});
  }

  Future<void> updateUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).update(user.toMap());
  }

  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }

  // Rating methods
  Future<void> updateFieldRating(String fieldId, double rating) async {
    final fieldRef = _firestore.collection('fields').doc(fieldId);
    final fieldDoc = await fieldRef.get();
    final field = FieldModel.fromMap({'id': fieldDoc.id, ...fieldDoc.data()!});

    final newTotalRatings = field.totalRatings + 1;
    final newRating =
        ((field.rating * field.totalRatings) + rating) / newTotalRatings;

    await fieldRef.update({
      'rating': newRating,
      'totalRatings': newTotalRatings,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<bool> isTimeSlotAvailable(
    String fieldId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      final fieldDoc = await _firestore.collection('fields').doc(fieldId).get();
      if (!fieldDoc.exists) {
        throw Exception('Field not found');
      }
      final field =
          FieldModel.fromMap({'id': fieldDoc.id, ...fieldDoc.data()!});
      final dayOfWeek = _getDayOfWeek(startTime.weekday);
      if (field.isDayClosed(dayOfWeek)) {
        print('Day $dayOfWeek is closed for field ${field.name}');
        return false;
      }
      // Assume getIntervalsForDay returns a list of [start, end] pairs (TimeOfDay)
      final intervals = field.getIntervalsForDay(
          dayOfWeek); // e.g. [[10:00, 14:00], [16:00, 20:00]]
      final startTimeOfDay =
          TimeOfDay(hour: startTime.hour, minute: startTime.minute);
      final endTimeOfDay =
          TimeOfDay(hour: endTime.hour, minute: endTime.minute);
      if (intervals.isNotEmpty) {
        bool inside = false;
        for (final interval in intervals) {
          final intervalStart = interval[0];
          final intervalEnd = interval[1];
          if (!_isTimeOfDayBefore(startTimeOfDay, intervalStart) &&
              !_isTimeOfDayAfter(endTimeOfDay, intervalEnd)) {
            inside = true;
            break;
          }
        }
        if (!inside) {
          print('Time slot not inside any custom interval');
          return false;
        }
      } else {
        // Use default opening/closing
        if (_isTimeOfDayBefore(startTimeOfDay, field.openingTime) ||
            _isTimeOfDayAfter(endTimeOfDay, field.closingTime)) {
          print('Time slot outside default operating hours');
          return false;
        }
      }
      final querySnapshot = await _firestore
          .collection('bookings')
          .where('fieldId', isEqualTo: fieldId)
          .where('status', whereIn: ['confirmed', 'pending']).get();

      for (final doc in querySnapshot.docs) {
        final booking = BookingModel.fromMap({'id': doc.id, ...doc.data()});
        // Only block if the exact same time slot is booked
        if (startTime.isAtSameMomentAs(booking.startTime) &&
            endTime.isAtSameMomentAs(booking.endTime)) {
          print('Time slot overlaps with existing booking');
          return false;
        }
      }
      print('Time slot is available');
      return true;
    } catch (e) {
      print('Error checking time slot availability: $e');
      rethrow;
    }
  }

  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        throw Exception('Invalid weekday');
    }
  }

  bool _isTimeOfDayBefore(TimeOfDay t1, TimeOfDay t2) {
    // Returns true if t1 < t2
    return t1.hour < t2.hour || (t1.hour == t2.hour && t1.minute < t2.minute);
  }

  bool _isTimeOfDayAfter(TimeOfDay t1, TimeOfDay t2) {
    // Returns true if t1 > t2
    return t1.hour > t2.hour || (t1.hour == t2.hour && t1.minute > t2.minute);
  }

  Future<List<DateTime>> getAvailableTimeSlots(
    String fieldId,
    DateTime date,
    TimeOfDay openingTime,
    TimeOfDay closingTime,
  ) async {
    final List<DateTime> availableSlots = [];
    final fieldDoc = await _firestore.collection('fields').doc(fieldId).get();
    if (!fieldDoc.exists) return [];
    final field = FieldModel.fromMap({'id': fieldDoc.id, ...fieldDoc.data()!});
    final dayOfWeek = _getDayOfWeek(date.weekday);

    if (field.isDayClosed(dayOfWeek)) {
      return [];
    }

    final intervals = field.getIntervalsForDay(dayOfWeek);

    if (intervals.isNotEmpty) {
      // Generate slots only within custom intervals
      for (final interval in intervals) {
        final intervalStart = interval[0];
        final intervalEnd = interval[1];
        DateTime currentSlot = DateTime(date.year, date.month, date.day,
            intervalStart.hour, intervalStart.minute);
        final DateTime endOfInterval = DateTime(date.year, date.month, date.day,
            intervalEnd.hour, intervalEnd.minute);
        while (currentSlot.isBefore(endOfInterval)) {
          final nextSlot = currentSlot.add(const Duration(hours: 1));
          if (nextSlot.isAfter(endOfInterval)) break;
          if (await isTimeSlotAvailable(fieldId, currentSlot, nextSlot)) {
            availableSlots.add(currentSlot);
          }
          currentSlot = nextSlot;
        }
      }
    } else {
      // Use default opening/closing
      DateTime currentSlot = DateTime(date.year, date.month, date.day,
          openingTime.hour, openingTime.minute);
      final DateTime endOfDay = DateTime(date.year, date.month, date.day,
          closingTime.hour, closingTime.minute);
      while (currentSlot.isBefore(endOfDay)) {
        final nextSlot = currentSlot.add(const Duration(hours: 1));
        if (nextSlot.isAfter(endOfDay)) break;
        if (await isTimeSlotAvailable(fieldId, currentSlot, nextSlot)) {
          availableSlots.add(currentSlot);
        }
        currentSlot = nextSlot;
      }
    }

    return availableSlots;
  }

  Future<void> launchSms(String phoneNumber, String message) async {
    try {
      print("Attempting to launch SMS app for: $phoneNumber");
      print("Message: $message");

      // Clean the phone number (remove spaces and other characters)
      phoneNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');

      // Build the SMS URI
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: phoneNumber,
        queryParameters: {'body': message},
      );

      print("SMS URI: $smsUri");

      if (await canLaunchUrl(smsUri)) {
        print("Launching SMS app...");
        await launchUrl(smsUri);
        print("SMS app launched successfully");
      } else {
        print("Could not launch SMS app");
        // Try a more basic approach as fallback
        final fallbackUri =
            Uri.parse('sms:$phoneNumber?body=${Uri.encodeComponent(message)}');
        print("Trying fallback URI: $fallbackUri");
        await launchUrl(fallbackUri);
      }
    } catch (e) {
      print("Error launching SMS app: $e");
      rethrow;
    }
  }

  Future<void> confirmBooking(String bookingId) async {
    try {
      final bookingDoc =
          await _firestore.collection('bookings').doc(bookingId).get();
      if (!bookingDoc.exists) {
        throw Exception('Booking not found');
      }

      final booking =
          BookingModel.fromMap({'id': bookingDoc.id, ...bookingDoc.data()!});
      if (booking.status != 'pending') {
        throw Exception('Booking is not in pending status');
      }

      // Update booking status with a transaction to ensure consistency
      await _firestore.runTransaction((transaction) async {
        final bookingRef = _firestore.collection('bookings').doc(bookingId);
        transaction.update(bookingRef, {
          'status': 'confirmed',
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      });

      // Get the user who made the booking
      final userDoc =
          await _firestore.collection('users').doc(booking.userId).get();
      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      final user = UserModel.fromMap({'id': userDoc.id, ...userDoc.data()!});

      // Open SMS app with pre-filled message
      await launchSms(user.phone,
          'Votre réservation pour ${booking.fieldName ?? 'le terrain'} le ${booking.startTime.toString().split(' ')[0]} à ${booking.startTime.toString().split(' ')[1].substring(0, 5)} a été confirmée.');

      // Optionally: still send push notification
      // final notificationService = NotificationService();
      // await notificationService.sendBookingConfirmationNotification(
      //     booking, user);
    } catch (e) {
      print('Error confirming booking: $e');
      rethrow;
    }
  }

  // Reviews
  Stream<List<ReviewModel>> getFieldReviews(String fieldId) {
    return _firestore
        .collection('fields')
        .doc(fieldId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReviewModel.fromMap({'id': doc.id, ...doc.data()}))
          .toList();
    });
  }

  Future<void> addReview(ReviewModel review) async {
    try {
      final fieldRef = _firestore.collection('fields').doc(review.fieldId);
      final reviewRef = fieldRef.collection('reviews').doc(review.id);

      await _firestore.runTransaction((transaction) async {
        // Verify field exists
        final fieldDoc = await transaction.get(fieldRef);
        if (!fieldDoc.exists) {
          throw Exception('Terrain non trouvé');
        }

        // Add the review
        transaction.set(reviewRef, {
          ...review.toMap(),
          'createdAt': Timestamp.fromDate(review.createdAt),
          'updatedAt': Timestamp.fromDate(review.updatedAt),
        });

        // Update field rating
        final field =
            FieldModel.fromMap({'id': fieldDoc.id, ...fieldDoc.data()!});
        final newTotalRatings = field.totalRatings + 1;
        final newRating =
            ((field.rating * field.totalRatings) + review.rating) /
                newTotalRatings;

        transaction.update(fieldRef, {
          'rating': newRating,
          'totalRatings': newTotalRatings,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      });
    } catch (e) {
      print('Error adding review: $e');
      rethrow;
    }
  }

  Future<void> updateReview(ReviewModel review) async {
    final fieldRef = _firestore.collection('fields').doc(review.fieldId);
    final reviewRef = fieldRef.collection('reviews').doc(review.id);

    await _firestore.runTransaction((transaction) async {
      // Get the old review
      final oldReviewDoc = await transaction.get(reviewRef);
      if (!oldReviewDoc.exists) {
        throw Exception('Review not found');
      }

      final oldReview =
          ReviewModel.fromMap({'id': oldReviewDoc.id, ...oldReviewDoc.data()!});

      // Update the review
      transaction.update(reviewRef, review.toMap());

      // Update field rating
      final fieldDoc = await transaction.get(fieldRef);
      if (fieldDoc.exists) {
        final field =
            FieldModel.fromMap({'id': fieldDoc.id, ...fieldDoc.data()!});
        final newRating = ((field.rating * field.totalRatings) -
                oldReview.rating +
                review.rating) /
            field.totalRatings;

        transaction.update(fieldRef, {
          'rating': newRating,
        });
      }
    });
  }

  Future<void> deleteReview(String reviewId, String fieldId) async {
    final fieldRef = _firestore.collection('fields').doc(fieldId);
    final reviewRef = fieldRef.collection('reviews').doc(reviewId);

    await _firestore.runTransaction((transaction) async {
      // Get the review
      final reviewDoc = await transaction.get(reviewRef);
      if (!reviewDoc.exists) {
        throw Exception('Review not found');
      }

      final review =
          ReviewModel.fromMap({'id': reviewDoc.id, ...reviewDoc.data()!});

      // Delete the review
      transaction.delete(reviewRef);

      // Update field rating
      final fieldDoc = await transaction.get(fieldRef);
      if (fieldDoc.exists) {
        final field =
            FieldModel.fromMap({'id': fieldDoc.id, ...fieldDoc.data()!});
        final newTotalRatings = field.totalRatings - 1;
        final newRating = newTotalRatings > 0
            ? ((field.rating * field.totalRatings) - review.rating) /
                newTotalRatings
            : 0.0;

        transaction.update(fieldRef, {
          'rating': newRating,
          'totalRatings': newTotalRatings,
        });
      }
    });
  }
}
