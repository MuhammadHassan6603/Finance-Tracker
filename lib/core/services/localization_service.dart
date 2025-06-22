import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../generated/l10n.dart';

class LocalizationService {
  // Supported locales
  static final List<Locale> supportedLocales = [
    const Locale('en', ''), // English
    const Locale('es', ''), // Spanish
    const Locale('fr', ''), // French
    const Locale('hi', 'IN'), // Hindi with country code
    const Locale('ar', 'SA'), // Arabic with country code
  ];

  // Localization delegates used by the app
  static final List<LocalizationsDelegate> localizationDelegates = [
    AppLocalizations.delegate, // Generated delegate from intl
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  // Helper method to get locale from language code
  static Locale? localeFromString(String? languageCode) {
    if (languageCode == null || languageCode.isEmpty) return null;

    // Return the locale with appropriate country code for Arabic and Hindi
    switch (languageCode) {
      case 'ar':
        return const Locale('ar', 'SA');
      case 'hi':
        return const Locale('hi', 'IN');
      default:
        return supportedLocales.firstWhere(
          (locale) => locale.languageCode == languageCode,
          orElse: () => supportedLocales.first,
        );
    }
  }

  // Get language name from locale
  static String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'ar':
        return 'العربية';  // Native name for Arabic
      case 'hi':
        return 'हिंदी';    // Native name for Hindi
      default:
        return 'Unknown';
    }
  }
}
