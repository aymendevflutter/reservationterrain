class AppConstants {
  // API Keys and URLs
  static const String cloudinaryCloudName = 'YOUR_CLOUDINARY_CLOUD_NAME';
  static const String cloudinaryUploadPreset = 'YOUR_CLOUDINARY_UPLOAD_PRESET';
  static const String flouciApiKey = 'YOUR_FLOUCI_API_KEY';
  static const String flouciApiUrl = 'https://api.flouci.com/v1';

  // Collection names
  static const String fieldsCollection = 'fields';
  static const String bookingsCollection = 'bookings';
  static const String paymentsCollection = 'payments';
  static const String usersCollection = 'users';

  // User roles
  static const String userRole = 'user';
  static const String ownerRole = 'owner';

  // Booking status
  static const String pendingStatus = 'pending';
  static const String confirmedStatus = 'confirmed';
  static const String cancelledStatus = 'cancelled';
  static const String completedStatus = 'completed';

  // Payment status
  static const String paymentPending = 'pending';
  static const String paymentCompleted = 'completed';
  static const String paymentFailed = 'failed';
  static const String paymentRefunded = 'refunded';

  // Payment Methods
  static const String paymentMethodFlouci = 'flouci';
  static const String paymentMethodEDinar = 'edinar';

  // Time Slots
  static const List<String> timeSlots = [
    '08:00 - 09:00',
    '09:00 - 10:00',
    '10:00 - 11:00',
    '11:00 - 12:00',
    '12:00 - 13:00',
    '13:00 - 14:00',
    '14:00 - 15:00',
    '15:00 - 16:00',
    '16:00 - 17:00',
    '17:00 - 18:00',
    '18:00 - 19:00',
    '19:00 - 20:00',
    '20:00 - 21:00',
    '21:00 - 22:00',
  ];

  // Local Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userRoleKey = 'user_role';
  static const String userLanguageKey = 'user_language';

  // Supported Languages
  static const String defaultLanguage = 'fr';
  static const List<String> supportedLanguages = ['fr', 'ar'];

  // Error Messages
  static const String errorGeneric =
      'Une erreur est survenue. Veuillez réessayer.';
  static const String errorNoInternet =
      'Pas de connexion Internet. Veuillez vérifier votre connexion et réessayer.';
  static const String errorInvalidCredentials =
      'Email ou mot de passe invalide.';
  static const String errorEmailInUse = 'Cet email est déjà utilisé.';
  static const String errorWeakPassword =
      'Le mot de passe fourni est trop faible.';
  static const String errorUserNotFound =
      'Aucun utilisateur trouvé avec cet email.';
  static const String errorWrongPassword = 'Mot de passe incorrect.';
  static const String errorInvalidEmail = 'L\'adresse email est invalide.';
  static const String errorOperationNotAllowed = 'Opération non autorisée.';
  static const String errorTooManyRequests =
      'Trop de tentatives. Veuillez réessayer plus tard.';

  // Success Messages
  static const String successLogin = 'Connexion réussie.';
  static const String successRegister = 'Inscription réussie.';
  static const String successLogout = 'Déconnexion réussie.';
  static const String successBooking = 'Réservation créée avec succès.';
  static const String successPayment = 'Paiement effectué avec succès.';
  static const String successProfileUpdate = 'Profil mis à jour avec succès.';

  // Cache Keys
  static const String languageCacheKey = 'language_cache_key';
}
