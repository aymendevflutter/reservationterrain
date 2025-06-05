import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class AppConfig {
  // App Info
  static const String appName = 'Field Reserve';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Environment
  static const bool isDevelopment = true;
  static const bool isProduction = false;

  // Cloudinary
  static const String cloudinaryCloudName = 'dmps9fz5k';
  static const String cloudinaryUploadPreset = 'reservation';

  // ImgBB
  static const String imgbbApiKey = '6fd91f2fade9588ac0998b76dc3ea987';
  static const String imgbbBaseUrl = 'https://api.imgbb.com/1/upload';

  // Notifications
  static String get notificationChannelId => 'field_reserve_channel';
  static String get notificationChannelName => 'Field Reserve Notifications';
  static String get notificationChannelDescription =>
      'Notifications for Field Reserve Tunisia';
  static const int reminderHours = 2;

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Cache
  static const Duration cacheMaxAge = Duration(hours: 24);
  static const int maxCacheSize = 100;

  // Image Upload
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxImagesPerField = 5;
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];

  // Validation
  static const int passwordMinLength = 8;
  static const int nameMinLength = 3;
  static const int phoneLength = 8;

  // Booking
  static const int maxBookingsPerUser = 10;
  static const int maxBookingDays = 30;
  static const int minBookingHours = 1;
  static const int maxBookingHours = 4;
  static const double minPrice = 20;
  static const double maxPrice = 500;

  // Map
  static const double defaultLatitude = 36.8065;
  static const double defaultLongitude = 10.1815;
  static const double defaultZoom = 12;
  static const int searchRadius = 50; // km

  // Pagination
  static const int pageSize = 20;
  static const int maxPages = 50;

  // Rate Limiting
  static const int maxRequestsPerMinute = 60;
  static const int maxLoginAttempts = 5;
  static const Duration loginLockoutDuration = Duration(minutes: 15);

  // Session
  static const Duration sessionTimeout = Duration(hours: 24);
  static const Duration refreshTokenValidity = Duration(days: 30);

  static const int maxRating = 5;
  static const int minRating = 1;

  static const List<String> bookingStatuses = [
    'pending',
    'confirmed',
    'cancelled',
    'completed',
  ];

  static const Map<String, String> bookingStatusColors = {
    'pending': '#FFA500',
    'confirmed': '#4CAF50',
    'cancelled': '#F44336',
    'completed': '#2196F3',
  };

  // Payment Configuration
  static const String flouciApiKey = 'YOUR_FLOUCI_API_KEY';
  static const String edinarApiKey = 'YOUR_EDINAR_API_KEY';
  static const String flouciSuccessUrl = 'https://your-app.com/payment/success';
  static const String flouciCancelUrl = 'https://your-app.com/payment/cancel';
  static const String flouciWebhookUrl = 'https://your-app.com/payment/webhook';
  static const String edinarSuccessUrl = 'https://your-app.com/payment/success';
  static const String edinarCancelUrl = 'https://your-app.com/payment/cancel';
  static const String edinarWebhookUrl = 'https://your-app.com/payment/webhook';

  static Future<void> initialize() async {
    // Initialize timezone data for notifications
    tz.initializeTimeZones();
  }
}
