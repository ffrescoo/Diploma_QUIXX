import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _userNicknameKey = 'user_nickname';

  // Сохранить никнейм
  static Future<void> saveNickname(String nickname) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNicknameKey, nickname);
  }

  // Получить никнейм (синхронно или через Future)
  static Future<String?> getNickname() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNicknameKey);
  }

  // Удалить при выходе из аккаунта
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userNicknameKey);
  }
}