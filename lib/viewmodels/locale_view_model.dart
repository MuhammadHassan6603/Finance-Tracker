import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/services/localization_service.dart';
import '../core/services/preferences_service.dart';
import '../l10n/models/locale_model.dart';

class LocaleViewModel extends ChangeNotifier {
  final PreferencesService _preferencesService = PreferencesService();

  LocaleModel? _localeModel;
  bool _isLoading = true;

  // Getters
  LocaleModel? get localeModel => _localeModel;

  bool get isLoading => _isLoading;

  Locale? get locale => _localeModel?.locale;

  bool get isSystemDefault => _localeModel?.isSystemDefault ?? true;

  // Constructor loads saved locale
  LocaleViewModel() {
    loadSavedLocale();
  }

  // Load saved locale from preferences
  Future<void> loadSavedLocale() async {
    _isLoading = true;
    notifyListeners();

    final String? savedLanguageCode =
        await _preferencesService.getLanguageCode();

    if (savedLanguageCode == null) {
      // Use system locale if no preference is saved
      final systemLocale = ui.window.locale;
      _localeModel = LocaleModel(
        // Ensure proper locale is set for Arabic and Hindi
        locale: LocalizationService.localeFromString(systemLocale.languageCode) ?? systemLocale,
        isSystemDefault: true,
      );
    } else {
      // Use saved locale with proper country codes
      _localeModel = LocaleModel(
        locale: LocalizationService.localeFromString(savedLanguageCode)!,
        isSystemDefault: false,
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  // Set a new locale
  Future<void> setLocale(Locale newLocale) async {
    // Save to preferences
    await _preferencesService.setLanguageCode(newLocale.languageCode);

    // Update model with proper locale including country code
    _localeModel = LocaleModel(
      locale: LocalizationService.localeFromString(newLocale.languageCode) ?? newLocale,
      isSystemDefault: false,
    );

    notifyListeners();
  }

  // Use system default locale
  Future<void> useSystemLocale() async {
    // Clear saved preference
    await _preferencesService.clearLanguageCode();

    final systemLocale = ui.window.locale;
    // Update model with proper locale including country code
    _localeModel = LocaleModel(
      locale: LocalizationService.localeFromString(systemLocale.languageCode) ?? systemLocale,
      isSystemDefault: true,
    );

    notifyListeners();
  }
}
