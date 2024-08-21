import "package:shared_preferences/shared_preferences.dart";

class Settings {
  static const String _keyShowOnboarding = 'showOnboarding';

  static Future<bool> getShowOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyShowOnboarding) ?? false;
  }

  static Future<void> setShowOnboarding(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowOnboarding, value);
  }
}
