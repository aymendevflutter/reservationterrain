import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart' as app_theme;
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/cloudinary_service.dart';
import 'services/payment_service.dart';
import 'services/notification_service.dart';
import 'providers/auth_provider.dart';
import 'providers/field_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/localization_provider.dart';
import 'views/splash/splash_screen.dart';
import 'views/auth/login_screen.dart';
import 'views/user/user_home_screen.dart';
import 'views/owner/owner_home_screen.dart';
import 'services/imgbb_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize app config
  await AppConfig.initialize();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize NotificationService
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(
  //  DevicePreview(
   //   enabled: !kReleaseMode, // Only enabled in debug mode
    //  builder: (context) =>
       MyApp(prefs: prefs), // Pass prefs through
    //),
  );
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        Provider<CloudinaryService>(create: (_) => CloudinaryService()),
        Provider<PaymentService>(create: (_) => PaymentService()),
        Provider<NotificationService>(create: (_) => NotificationService()),
        Provider<ImgBBService>(create: (_) => ImgBBService()),

        // Providers with ChangeNotifier
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<FirestoreService, FieldProvider>(
          create: (context) => FieldProvider(
            firestoreService: context.read<FirestoreService>(),
          ),
          update: (context, firestoreService, previous) => FieldProvider(
            firestoreService: firestoreService,
          ),
        ),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => LocalizationProvider(prefs)),
      ],
      child: MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: app_theme.AppTheme.lightTheme,
        darkTheme: app_theme.AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('fr', ''), // French
          Locale('ar', ''), // Arabic
        ],
        locale: const Locale('fr', ''), // Set French as default
        initialRoute: '/',
        routes: {
          '/': (context) => AuthWrapper(),
          '/login': (context) => const LoginScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context.read<AuthService>().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          // Check user type and return appropriate screen
          return FutureBuilder<String?>(
            future: context.read<AuthService>().getUserType(),
            builder: (context, userTypeSnapshot) {
              if (userTypeSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final userType = userTypeSnapshot.data;
              if (userType == 'owner') {
                return const OwnerHomeScreen();
              } else {
                return const UserHomeScreen();
              }
            },
          );
        }

        return const LoginScreen();
      },
    );
  }
}
