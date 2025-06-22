import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:currency_picker/currency_picker.dart';

class SessionManager extends ChangeNotifier {
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';
  static const String _hasSelectedCurrencyKey = 'has_selected_currency';
  static const String _selectedCurrencyKey = 'selected_currency';
  static const String _selectedCurrencySymbolKey = 'selected_currency_symbol';

  final SharedPreferences _prefs;
  final FirebaseAuth _auth;

  SessionManager({
    required SharedPreferences prefs,
    FirebaseAuth? auth,
  })  : _prefs = prefs,
        _auth = auth ?? FirebaseAuth.instance {
    // Listen to auth state changes
    _auth.authStateChanges().listen((user) {
      notifyListeners();
    });
  }

  bool get isAuthenticated => _auth.currentUser != null;

  bool get hasSeenOnboarding => _prefs.getBool(_hasSeenOnboardingKey) ?? false;

  bool get hasSelectedCurrency => _prefs.getBool(_hasSelectedCurrencyKey) ?? false;

  String? get selectedCurrency => _prefs.getString(_selectedCurrencyKey);
  String? get selectedCurrencySymbol => _prefs.getString(_selectedCurrencySymbolKey) ?? '\$';

  Future<void> setHasSeenOnboarding(bool value) async {
    await _prefs.setBool(_hasSeenOnboardingKey, value);
    notifyListeners();
  }

  Future<void> setHasSelectedCurrency(bool value) async {
    await _prefs.setBool(_hasSelectedCurrencyKey, value);
    notifyListeners();
  }

  Future<void> setSelectedCurrency(String currency) async {
    await _prefs.setString(_selectedCurrencyKey, currency);
    // Get the currency symbol from the currency_picker package
    final currencyInfo = CurrencyService().findByCode(currency);
    if (currencyInfo != null) {
      await _prefs.setString(_selectedCurrencySymbolKey, currencyInfo.symbol);
    }
    await setHasSelectedCurrency(true);
    notifyListeners();
  }

  Future<void> clearSession() async {
    await _auth.signOut();
    // Don't clear onboarding and currency selection flags
    notifyListeners();
  }

  // Add method to handle authentication success
  Future<void> onAuthenticationSuccess() async {
    notifyListeners();
  }

  // Add method to handle sign out
  Future<void> signOut() async {
    await clearSession();
    notifyListeners();
  }
}
