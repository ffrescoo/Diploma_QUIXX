import 'local_storage.dart';

class UserSession {
  static String nickname = 'Quixx User';

  static Future<void> init() async {
    final savedName = await LocalStorage.getNickname();
    if (savedName != null) {
      nickname = savedName;
    }
  }
}