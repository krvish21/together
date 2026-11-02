import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String keyCoupleId = 'together_couple_id';
  static const String keySpaceCode = 'together_space_code';
  static const String keyMyRole = 'together_my_role'; // 'partner1' or 'partner2'
  static const String keyServerUrl = 'together_server_url';
  static const String keyThemeMode = 'together_theme_mode';

  static Future<void> saveCoupleSession({
    required String coupleId,
    required String spaceCode,
    required String myRole,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyCoupleId, coupleId);
    await prefs.setString(keySpaceCode, spaceCode);
    await prefs.setString(keyMyRole, myRole);
  }

  static Future<Map<String, String?>> getCoupleSession() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'coupleId': prefs.getString(keyCoupleId),
      'spaceCode': prefs.getString(keySpaceCode),
      'myRole': prefs.getString(keyMyRole),
    };
  }

  static Future<void> setMyRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyMyRole, role);
  }

  static Future<String?> getServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyServerUrl);
  }

  static Future<void> setServerUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyServerUrl, url);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyCoupleId);
    await prefs.remove(keySpaceCode);
    await prefs.remove(keyMyRole);
  }
}
