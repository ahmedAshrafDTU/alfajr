import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Abstract key-value and document storage interface.
abstract class LocalStorageService {
  Future<void> init();
  Future<String?> readString(String key);
  Future<void> writeString(String key, String value);
  Future<Map<String, dynamic>?> readJson(String key);
  Future<void> writeJson(String key, Map<String, dynamic> value);
  Future<List<dynamic>?> readJsonList(String key);
  Future<void> writeJsonList(String key, List<dynamic> value);
  Future<void> remove(String key);
  Future<void> clear();
}

/// Robust JSON Local Storage implementation using SharedPreferences (Web/Mobile compatible).
class SharedPrefsLocalStorageService implements LocalStorageService {
  late SharedPreferences _prefs;
  bool _initialized = false;

  @override
  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  @override
  Future<String?> readString(String key) async {
    await init();
    return _prefs.getString(key);
  }

  @override
  Future<void> writeString(String key, String value) async {
    await init();
    await _prefs.setString(key, value);
  }

  @override
  Future<Map<String, dynamic>?> readJson(String key) async {
    final raw = await readString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> writeJson(String key, Map<String, dynamic> value) async {
    final raw = jsonEncode(value);
    await writeString(key, raw);
  }

  @override
  Future<List<dynamic>?> readJsonList(String key) async {
    final raw = await readString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as List<dynamic>;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> writeJsonList(String key, List<dynamic> value) async {
    final raw = jsonEncode(value);
    await writeString(key, raw);
  }

  @override
  Future<void> remove(String key) async {
    await init();
    await _prefs.remove(key);
  }

  @override
  Future<void> clear() async {
    await init();
    await _prefs.clear();
  }
}

