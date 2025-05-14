import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/config/app_config.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/booking_model.dart';
import '../models/user_model.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Request permission for notifications
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications
    const initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(initializationSettings);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle received messages when app is in foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;
    final data = message.data;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            AppConfig.notificationChannelId,
            AppConfig.notificationChannelName,
            channelDescription: AppConfig.notificationChannelDescription,
            importance: Importance.max,
            priority: Priority.high,
            icon: android?.smallIcon,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: data['route'],
      );
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    // Handle notification tap when app is in background
    final data = message.data;
    if (data['route'] != null) {
      // Navigate to specific screen based on route
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      // Navigate to specific screen based on payload
    }
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          AppConfig.notificationChannelId,
          AppConfig.notificationChannelName,
          channelDescription: AppConfig.notificationChannelDescription,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  Future<void> showBookingConfirmation({
    required String fieldName,
    required DateTime date,
    required String timeSlot,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'booking_confirmation',
      'Booking Confirmation',
      channelDescription: 'Notifications for booking confirmations',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotifications.show(
      0,
      'Réservation confirmée',
      'Votre réservation pour $fieldName le ${date.day}/${date.month}/${date.year} à $timeSlot a été confirmée.',
      details,
    );
  }

  Future<void> showBookingConfirmed({
    required String bookingId,
    required String fieldName,
    required DateTime date,
    required String timeSlot,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'booking_confirmed',
      'Booking Confirmed',
      channelDescription: 'Notifications for confirmed bookings',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotifications.show(
      1,
      'Réservation confirmée',
      'Votre réservation pour $fieldName le ${date.day}/${date.month}/${date.year} à $timeSlot a été confirmée par le propriétaire.',
      details,
    );
  }

  Future<void> showBookingCancelled({
    required String bookingId,
    required String fieldName,
    required DateTime date,
    required String timeSlot,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'booking_cancelled',
      'Booking Cancelled',
      channelDescription: 'Notifications for cancelled bookings',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotifications.show(
      2,
      'Réservation annulée',
      'Votre réservation pour $fieldName le ${date.day}/${date.month}/${date.year} à $timeSlot a été annulée.',
      details,
    );
  }

  Future<void> scheduleBookingReminder({
    required String fieldName,
    required DateTime date,
    required String timeSlot,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'booking_reminder',
      'Booking Reminder',
      channelDescription: 'Notifications for booking reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    // Schedule notification 1 hour before the booking
    final scheduledTime = tz.TZDateTime.from(
      date.subtract(const Duration(hours: 1)),
      tz.local,
    );

    await _localNotifications.zonedSchedule(
      3,
      'Rappel de réservation',
      'Vous avez une réservation pour $fieldName dans 1 heure à $timeSlot.',
      scheduledTime,
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> showRatingPrompt({
    required String fieldName,
    required DateTime date,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'rating_channel',
      'Rating Prompts',
      channelDescription: 'Notifications for rating prompts',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      2,
      'Rate Your Experience',
      'How was your experience at $fieldName on ${date.toString().split(' ')[0]}?',
      details,
    );
  }

  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  Future<void> sendBookingConfirmationEmail(
      BookingModel booking, UserModel user) async {
    try {
      // Get the field details
      final fieldDoc =
          await _firestore.collection('fields').doc(booking.fieldId).get();
      final fieldName = fieldDoc.data()?['name'] as String? ?? 'Unknown Field';

      // Format the date and time
      final date = booking.startTime.toString().split(' ')[0];
      final startTime =
          booking.startTime.toString().split(' ')[1].substring(0, 5);
      final endTime = booking.endTime.toString().split(' ')[1].substring(0, 5);

      // Prepare email content
      final emailContent = {
        'to': user.email,
        'subject': 'Confirmation de réservation - $fieldName',
        'html': '''
          <h2>Confirmation de réservation</h2>
          <p>Bonjour ${user.name},</p>
          <p>Votre réservation pour le terrain "$fieldName" a été confirmée.</p>
          <h3>Détails de la réservation :</h3>
          <ul>
            <li>Date : $date</li>
            <li>Heure de début : $startTime</li>
            <li>Heure de fin : $endTime</li>
            <li>Prix total : ${booking.totalPrice} TND</li>
            ${booking.withReferee ? '<li>Arbitre inclus</li>' : ''}
          </ul>
          <p>Merci de votre confiance !</p>
          <p>Cordialement,<br>L'équipe FieldReserve Tunisia</p>
        ''',
      };

      // Send email using Firebase Cloud Functions
      final response = await http.post(
        Uri.parse(
            'https://us-central1-your-project-id.cloudfunctions.net/sendEmail'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(emailContent),
      );

      if (response.statusCode != 200) {
        print('Failed to send confirmation email: ${response.body}');
        // Don't throw the error to prevent blocking the booking confirmation
      }
    } catch (e) {
      print('Error sending confirmation email: $e');
      // Don't throw the error to prevent blocking the booking confirmation
    }
  }

  Future<void> sendBookingConfirmationNotification(
      BookingModel booking, UserModel user) async {
    try {
      // Get the field details
      final fieldDoc =
          await _firestore.collection('fields').doc(booking.fieldId).get();
      final fieldName = fieldDoc.data()?['name'] as String? ?? 'Unknown Field';

      // Send local notification
      const androidDetails = AndroidNotificationDetails(
        'booking_confirmation_channel',
        'Booking Confirmations',
        channelDescription: 'Notifications for booking confirmations',
        importance: Importance.high,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails();

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        booking.id.hashCode,
        'Réservation confirmée',
        'Votre réservation pour $fieldName a été confirmée',
        notificationDetails,
      );

      // Send push notification if user has FCM token
      if (user.fcmToken != null) {
        await _messaging.sendMessage(
          to: user.fcmToken!,
          data: {
            'type': 'booking_confirmation',
            'bookingId': booking.id,
            'fieldName': fieldName,
          },
        );
      }
    } catch (e) {
      print('Error sending confirmation notification: $e');
    }
  }

  Future<void> sendNewBookingNotificationToOwner(
      BookingModel booking, UserModel client) async {
    try {
      // Get the field details
      final fieldDoc =
          await _firestore.collection('fields').doc(booking.fieldId).get();
      final fieldName = fieldDoc.data()?['name'] as String? ?? 'Unknown Field';
      final ownerId = fieldDoc.data()?['ownerId'] as String?;

      if (ownerId == null) {
        throw Exception('Field owner not found');
      }

      // Get the owner's user document
      final ownerDoc = await _firestore.collection('users').doc(ownerId).get();
      if (!ownerDoc.exists) {
        throw Exception('Field owner not found');
      }

      final owner = UserModel.fromMap({'id': ownerDoc.id, ...ownerDoc.data()!});

      // Format the date and time
      final date = booking.startTime.toString().split(' ')[0];
      final startTime =
          booking.startTime.toString().split(' ')[1].substring(0, 5);
      final endTime = booking.endTime.toString().split(' ')[1].substring(0, 5);

      // Send local notification
      const androidDetails = AndroidNotificationDetails(
        'new_booking_channel',
        'New Bookings',
        channelDescription: 'Notifications for new bookings',
        importance: Importance.high,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails();

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        booking.id.hashCode,
        'Nouvelle réservation',
        'Nouvelle réservation pour $fieldName par ${client.name} le $date de $startTime à $endTime',
        notificationDetails,
      );

      // Send push notification if owner has FCM token
      if (owner.fcmToken != null) {
        await _messaging.sendMessage(
          to: owner.fcmToken!,
          data: {
            'type': 'new_booking',
            'bookingId': booking.id,
            'fieldName': fieldName,
            'clientName': client.name,
            'date': date,
            'startTime': startTime,
            'endTime': endTime,
          },
        );
      }
    } catch (e) {
      print('Error sending new booking notification to owner: $e');
    }
  }
}

// Handle background messages
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages here
  print('Handling background message: ${message.messageId}');
}
