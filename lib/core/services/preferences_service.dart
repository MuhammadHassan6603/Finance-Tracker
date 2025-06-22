import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String languageCodeKey = 'language_code';

  // Get saved language code
  Future<String?> getLanguageCode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(languageCodeKey);
  }

  // Save language code
  Future<bool> setLanguageCode(String? languageCode) async {
    if (languageCode == null) return false;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(languageCodeKey, languageCode);
  }

  // Clear language preference (revert to system default)
  Future<bool> clearLanguageCode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(languageCodeKey);
  }
}
