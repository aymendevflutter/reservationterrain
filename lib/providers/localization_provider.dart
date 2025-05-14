import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

class LocalizationProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  Locale _locale = const Locale('fr');

  LocalizationProvider(this._prefs) {
    _loadSavedLocale();
  }

  Locale get locale => _locale;

  Future<void> _loadSavedLocale() async {
    final savedLocale = _prefs.getString(AppConstants.languageCacheKey);
    if (savedLocale != null) {
      _locale = Locale(savedLocale);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale != locale) {
      _locale = locale;
      await _prefs.setString(
        AppConstants.languageCacheKey,
        locale.languageCode,
      );
      notifyListeners();
    }
  }

  Future<void> toggleLanguage() async {
    final newLocale =
        _locale.languageCode == 'fr' ? const Locale('ar') : const Locale('fr');
    await setLocale(newLocale);
  }
}
