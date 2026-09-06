import 'dart:convert';
import 'dart:io';

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

/// Robust JSON File-based Local Storage implementation.
/// Uses in-memory cache with async file persistence for high performance and durability.
class FileLocalStorageService implements LocalStorageService {
  final String storageDirectoryPath;
  final Map<String, String> _memoryCache = {};
  bool _initialized = false;

  FileLocalStorageService({this.storageDirectoryPath = '.alfager_data'});

  @override
  Future<void> init() async {
    if (_initialized) return;
    try {
      final dir = Directory(storageDirectoryPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      } else {
        // Preload files into memory cache
        await for (final entity in dir.list()) {
          if (entity is File && entity.path.endsWith('.json')) {
            final fileName = entity.uri.pathSegments.last;
            final key = fileName.replaceAll('.json', '');
            final content = await entity.readAsString();
            _memoryCache[key] = content;
          }
        }
      }
    } catch (_) {
      // Gracefully fall back to in-memory mode if filesystem permissions are restricted
    }
    _initialized = true;
  }

  @override
  Future<String?> readString(String key) async {
    await init();
    return _memoryCache[key];
  }

  @override
  Future<void> writeString(String key, String value) async {
    await init();
    _memoryCache[key] = value;
    try {
      final file = File('$storageDirectoryPath/$key.json');
      await file.writeAsString(value, flush: true);
    } catch (_) {
      // Maintained in memory cache
    }
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
    _memoryCache.remove(key);
    try {
      final file = File('$storageDirectoryPath/$key.json');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  @override
  Future<void> clear() async {
    await init();
    _memoryCache.clear();
    try {
      final dir = Directory(storageDirectoryPath);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (_) {}
  }
}
