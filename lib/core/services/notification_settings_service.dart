import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsService extends ChangeNotifier {
  static const String _budgetLimitsKey = 'budget_limits_notifications';
  static const String _billPaymentKey = 'bill_payment_notifications';
  
  final SharedPreferences _prefs;
  
  NotificationSettingsService(this._prefs);
  
  bool get budgetLimitsEnabled => _prefs.getBool(_budgetLimitsKey) ?? true;
  bool get billPaymentEnabled => _prefs.getBool(_billPaymentKey) ?? true;
  
  Future<void> setBudgetLimitsEnabled(bool enabled) async {
    await _prefs.setBool(_budgetLimitsKey, enabled);
    notifyListeners();
  }
  
  Future<void> setBillPaymentEnabled(bool enabled) async {
    await _prefs.setBool(_billPaymentKey, enabled);
    notifyListeners();
  }
} 