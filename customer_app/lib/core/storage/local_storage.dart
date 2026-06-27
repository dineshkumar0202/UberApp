import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'user_data';
  static const String _keyFcmToken = 'fcm_token';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<bool> saveToken(String token) async {
    return await _prefs?.setString(_keyToken, token) ?? false;
  }

  static String? getToken() {
    return _prefs?.getString(_keyToken);
  }

  static Future<bool> saveUser(Map<String, dynamic> userData) async {
    return await _prefs?.setString(_keyUser, jsonEncode(userData)) ?? false;
  }

  static Map<String, dynamic>? getUser() {
    final userStr = _prefs?.getString(_keyUser);
    if (userStr != null) {
      try {
        return jsonDecode(userStr) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static Future<bool> saveFcmToken(String token) async {
    return await _prefs?.setString(_keyFcmToken, token) ?? false;
  }

  static String? getFcmToken() {
    return _prefs?.getString(_keyFcmToken);
  }

  static Future<void> clearAll() async {
    await _prefs?.remove(_keyToken);
    await _prefs?.remove(_keyUser);
    // Note: We might want to preserve the FCM token across logouts so we can register it again when another user logs in
  }
}
