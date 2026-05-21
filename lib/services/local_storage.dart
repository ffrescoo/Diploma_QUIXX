import 'package:shared_preferences/shared_preferences.dart';



class LocalStorage {
  static const String _userNicknameKey = 'user_nickname';
  static const String _weightUnitKey = 'weight_unit_index';
  static const String _distanceUnitKey = 'distance_unit_index';
  static const String _measurementsUnitKey = 'measurements_unit_index';
  static const String _notificationsKey = 'notifications_enabled';

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
    await prefs.remove(_weightUnitKey);
    await prefs.remove(_distanceUnitKey);
    await prefs.remove(_measurementsUnitKey);
    await prefs.remove(_notificationsKey);
  }

  static Future<void> saveWeightUnit(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_weightUnitKey, index);
  }
  static Future<int> getWeightUnit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_weightUnitKey) ?? 0; // 0 (kg) за замовчуванням
  }

  static Future<void> saveDistanceUnit(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_distanceUnitKey, index);
  }
  static Future<int> getDistanceUnit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_distanceUnitKey) ?? 0; // 0 (km) за замовчуванням
  }

  static Future<void> saveMeasurementsUnit(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_measurementsUnitKey, index);
  }
  static Future<int> getMeasurementsUnit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_measurementsUnitKey) ?? 0; // 0 (cm) за замовчуванням
  }

  static Future<void> saveNotificationsState(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, isEnabled);
  }
  static Future<bool> getNotificationsState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsKey) ?? true; // true за замовчуванням
  }
}