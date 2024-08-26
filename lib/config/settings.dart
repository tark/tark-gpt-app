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

  static Future<List<String>> getChatList() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('chatHistory') ?? [];
  }

  static Future<void> saveChatList(List<String> chatList) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('chatHistory', chatList);
  }

  static Future<void> editChatName(String oldTitle, String newTitle) async {
    final prefs = await SharedPreferences.getInstance();
    final chatHistory = prefs.getStringList(oldTitle);
    if (chatHistory != null) {
      await prefs.setStringList(newTitle, chatHistory);
      await prefs.remove(oldTitle);
    }
  }

  static Future<void> deleteChat(String chatTitle) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(chatTitle);
  }

  static Future<void> setChatHistory(
      String chatTitle, List<String> chatHistory) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(chatTitle, chatHistory);
  }

  static Future<void> saveChatHistory(
      String chatTitle, List<String> chatHistory) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(chatTitle, chatHistory);
  }

  static Future<List<String>> getChatHistory(String chatTitle) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(chatTitle) ?? [];
  }
}
