# Field Reserve Tunisia 🏟️

A comprehensive Flutter application for booking and managing sports fields in Tunisia. This app connects field owners with players, allowing seamless reservations, payment processing, and field management.

## 📥 Download APK

[![Download APK](https://img.shields.io/badge/Download-APK-brightgreen?style=for-the-badge&logo=android)](https://github.com/yourusername/reservationterrain/releases/latest)

Get the latest version of the app:
- **Latest Release**: [Download APK v1.0.0](https://github.com/yourusername/reservationterrain/releases/latest)
- **Direct APK Link**: [field_reserve_tn_v1.0.0.apk](https://github.com/yourusername/reservationterrain/releases/download/v1.0.0/field_reserve_tn_v1.0.0.apk)

> **Note**: Make sure to enable "Install from Unknown Sources" in your Android device settings before installing the APK.

## 📸 Screenshots

<div align="center">

### Home Screen
<img src="screenshots/home_screen.png" alt="Home Screen" width="250"/>

### Field Details
<img src="screenshots/field_details.png" alt="Field Details" width="250"/>

### Booking Screen
<img src="screenshots/booking_screen.png" alt="Booking Screen" width="250"/>

### Owner Dashboard
<img src="screenshots/owner_dashboard.png" alt="Owner Dashboard" width="250"/>

### Login Screen
<img src="screenshots/login_screen.png" alt="Login Screen" width="250"/>

### Profile Screen
<img src="screenshots/profile_screen.png" alt="Profile Screen" width="250"/>

</div>

> **Note**: Add your screenshots to the `screenshots/` folder in the root directory. Supported formats: PNG, JPG. Recommended size: 1080x1920px (portrait) or 1920x1080px (landscape).

## 📱 About

Field Reserve Tunisia is a mobile application built with Flutter that enables users to discover, book, and manage sports field reservations. The app supports two user roles:

- **Users/Players**: Browse fields, make reservations, manage bookings, and make payments
- **Field Owners**: Add and manage fields, view bookings, set schedules, and track revenue

## ✨ Features

### For Users/Players
- 🔍 **Browse Fields**: Search and filter sports fields by location, price, features, and availability
- 👁️ **Guest Mode**: Browse fields without signing in (authentication required only for reservations)
- 📅 **Make Reservations**: Book fields with date and time selection
- 💳 **Payment Integration**: Support for Flouci and E-Dinar payment gateways
- 📋 **Booking Management**: View, track, and manage all your reservations
- ⭐ **Ratings & Reviews**: Rate and review fields after use
- 🗺️ **Location Services**: Find fields near you using GPS
- 🌐 **Multi-language**: Support for French and Arabic
- 📱 **Responsive Design**: Works on Android, iOS, Web, Windows, macOS, and Linux

### For Field Owners
- ➕ **Add Fields**: Create detailed field listings with images, features, and pricing
- 📊 **Manage Bookings**: View and manage all field reservations
- ⏰ **Weekly Schedule**: Set custom opening hours for each day of the week
- 📈 **Booking Analytics**: Track bookings and revenue
- ✏️ **Edit Fields**: Update field information, prices, and availability
- 📞 **Contact Management**: Manage field contact information

### General Features
- 🔐 **Authentication**: Secure login and registration with Firebase Auth
- 🔔 **Push Notifications**: Receive booking confirmations and reminders
- 💾 **Offline Support**: Cache data for offline browsing
- 🎨 **Modern UI**: Beautiful Material Design 3 interface with dark mode support
- 🔄 **Real-time Updates**: Live updates using Cloud Firestore
- 📸 **Image Upload**: Upload field images using Cloudinary or ImgBB
- 🗺️ **Maps Integration**: Google Maps integration for location services

## 🛠️ Tech Stack

### Frontend
- **Flutter** (SDK >=3.0.0 <4.0.0)
- **Dart** 3.0+
- **Provider** - State management
- **Material Design 3** - UI components

### Backend & Services
- **Firebase Core** - Backend infrastructure
- **Firebase Authentication** - User authentication
- **Cloud Firestore** - NoSQL database
- **Firebase Storage** - File storage
- **Firebase Cloud Messaging** - Push notifications

### Additional Packages
- **Cloudinary** - Image hosting and optimization
- **ImgBB** - Alternative image hosting
- **Google Maps Flutter** - Maps and location services
- **Geolocator** - Location services
- **Table Calendar** - Calendar widget for bookings
- **URL Launcher** - Open external links
- **Shared Preferences** - Local storage
- **Device Preview** - Multi-device preview (dev mode)

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (>=3.0.0)
- **Dart SDK** (>=3.0.0)
- **Android Studio** / **VS Code** with Flutter extensions
- **Firebase Account** with a project set up
- **Google Cloud Console** account (for Maps API)
- **Cloudinary Account** (optional, for image hosting)
- **ImgBB API Key** (optional, for image hosting)

## 🚀 Installation

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/reservationterrain.git
cd reservationterrain
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add Android and iOS apps to your Firebase project
3. Download configuration files:
   - `google-services.json` for Android (place in `android/app/`)
   - `GoogleService-Info.plist` for iOS (place in `ios/Runner/`)
4. Run `flutterfire configure` to generate `firebase_options.dart`

### 4. Configure API Keys

Update the following files with your API keys:

**`lib/core/config/app_config.dart`**:
```dart
static const String cloudinaryCloudName = 'YOUR_CLOUDINARY_CLOUD_NAME';
static const String cloudinaryUploadPreset = 'YOUR_CLOUDINARY_UPLOAD_PRESET';
static const String imgbbApiKey = 'YOUR_IMGBB_API_KEY';
```

**`lib/core/constants/app_constants.dart`**:
```dart
static const String flouciApiKey = 'YOUR_FLOUCI_API_KEY';
```

### 5. Google Maps Setup

1. Get a Google Maps API key from [Google Cloud Console](https://console.cloud.google.com/)
2. Add the key to:
   - **Android**: `android/app/src/main/AndroidManifest.xml`
   - **iOS**: `ios/Runner/AppDelegate.swift`

### 6. Run the App

```bash
# For development
flutter run

# For specific platform
flutter run -d android
flutter run -d ios
flutter run -d web
```

## 📁 Project Structure

```
lib/
├── core/
│   ├── config/          # App configuration
│   ├── constants/       # App constants
│   ├── theme/           # App theming
│   └── utils/           # Utility functions
├── models/              # Data models
│   ├── booking_model.dart
│   ├── field_model.dart
│   ├── user_model.dart
│   └── ...
├── providers/           # State management (Provider)
│   ├── auth_provider.dart
│   ├── field_provider.dart
│   └── booking_provider.dart
├── services/           # Business logic services
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   ├── cloudinary_service.dart
│   └── payment_service.dart
├── views/              # UI screens
│   ├── auth/           # Authentication screens
│   ├── user/           # User screens
│   ├── owner/          # Owner screens
│   └── client/         # Shared screens
├── widgets/            # Reusable widgets
└── main.dart           # App entry point
```

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the root directory (optional):

```env
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_UPLOUD_PRESET=your_preset
IMGBB_API_KEY=your_imgbb_key
FLOUCI_API_KEY=your_flouci_key
```

### Firebase Security Rules

Set up Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    match /fields/{fieldId} {
      allow read: if true; // Public read
      allow write: if request.auth != null && 
        request.auth.uid == resource.data.ownerId;
    }
    match /bookings/{bookingId} {
      allow read: if request.auth != null && 
        (request.auth.uid == resource.data.userId || 
         request.auth.uid == resource.data.ownerId);
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        (request.auth.uid == resource.data.userId || 
         request.auth.uid == resource.data.ownerId);
    }
  }
}
```

## 📱 Usage

### For Users

1. **Browse Fields**: Open the app and browse available sports fields
2. **Search & Filter**: Use search bar and filters to find specific fields
3. **View Details**: Tap on a field to see details, features, and pricing
4. **Make Reservation**: 
   - Select date and time
   - Choose additional services (referee, etc.)
   - Sign in if you're a guest
   - Complete payment
5. **Manage Bookings**: View all your reservations in the Bookings tab

### For Owners

1. **Sign Up as Owner**: Register with the "owner" role
2. **Add Field**: Use the "+" button to add a new field
3. **Set Schedule**: Configure weekly opening hours
4. **Manage Bookings**: View and confirm/cancel bookings
5. **Update Field**: Edit field information anytime

## 🧪 Testing

Run tests with:

```bash
flutter test
```

## 🚢 Building for Production

### Android

```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

## 🌍 Localization

The app supports multiple languages:
- **French** (fr) - Default
- **Arabic** (ar)

To add more languages, update `lib/core/constants/app_constants.dart` and add translation files.

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Authors

- **Aymen Fridhi** - *Initial work* - [GitHub](https://github.com/aymenfridhi) - [Email](mailto:aymen.fridhi@example.com)

## 🙏 Acknowledgments

- Firebase team for excellent backend services
- Flutter team for the amazing framework
- All open-source contributors whose packages made this possible

## 📞 Support

For support, email aymen.fridhi@example.com or open an issue in the repository.

## 🔮 Roadmap

- [ ] Real-time chat between users and owners
- [ ] Advanced analytics dashboard for owners
- [ ] Social features (share fields, invite friends)
- [ ] Loyalty program
- [ ] Mobile payment integration (Tunisian payment gateways)
- [ ] Weather integration for outdoor fields
- [ ] Video previews for fields
- [ ] Multi-currency support

---

Made with ❤️ in Tunisia 🇹🇳
