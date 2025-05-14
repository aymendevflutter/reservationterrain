import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_config.dart';

class AppUtils {
  static String formatCurrency(double amount) {
    return NumberFormat.currency(
      symbol: 'TND',
      decimalDigits: 2,
    ).format(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dt);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
  }

  static Future<bool> launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await url_launcher.canLaunchUrl(uri)) {
      return await url_launcher.launchUrl(uri);
    }
    return false;
  }

  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return await Geolocator.getCurrentPosition();
  }

  static double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)}m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)}km';
    }
  }

  static DateTime toDateTime(Timestamp timestamp) {
    return timestamp.toDate();
  }

  static Timestamp toTimestamp(DateTime dateTime) {
    return Timestamp.fromDate(dateTime);
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    return RegExp(r'^[0-9]{8}$').hasMatch(phone);
  }

  static bool isValidPassword(String password) {
    return password.length >= AppConfig.passwordMinLength;
  }

  static String getInitials(String name) {
    if (name.isEmpty) return '';
    final nameParts = name.split(' ');
    if (nameParts.length == 1) return nameParts[0][0].toUpperCase();
    return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
  }

  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  static String getBookingStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return '#4CAF50'; // Green
      case 'pending':
        return '#FFC107'; // Yellow
      case 'cancelled':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }

  static IconData getPaymentMethodIcon(String method) {
    switch (method) {
      case 'flouci':
        return Icons.payment;
      case 'edinar':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }

  static IconData getRoleIcon(String role) {
    switch (role) {
      case 'user':
        return Icons.person;
      case 'owner':
        return Icons.business;
      default:
        return Icons.person;
    }
  }
}
