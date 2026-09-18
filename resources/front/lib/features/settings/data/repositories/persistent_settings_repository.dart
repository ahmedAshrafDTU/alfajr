import '../../../../core/storage/local_storage_service.dart';
import '../../domain/models/app_settings_model.dart';
import 'settings_repository.dart';

/// Persistent Settings Repository with durable local storage.
class PersistentSettingsRepository implements SettingsRepository {
  static const String _storageKey = 'alfager_settings';
  final LocalStorageService storageService;
  AppSettingsModel? _cachedSettings;

  PersistentSettingsRepository({required this.storageService});

  @override
  Future<AppSettingsModel> getSettings() async {
    if (_cachedSettings != null) return _cachedSettings!;
    final json = await storageService.readJson(_storageKey);
    if (json != null) {
      _cachedSettings = AppSettingsModel.fromJson(json);
    } else {
      _cachedSettings = const AppSettingsModel();
      await saveSettings(_cachedSettings!);
    }
    return _cachedSettings!;
  }

  @override
  Future<void> saveSettings(AppSettingsModel settings) async {
    _cachedSettings = settings;
    await storageService.writeJson(_storageKey, settings.toJson());
  }
}
