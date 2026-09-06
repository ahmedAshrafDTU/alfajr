import '../../domain/models/app_settings_model.dart';

abstract class SettingsRepository {
  Future<AppSettingsModel> getSettings();
  Future<void> saveSettings(AppSettingsModel settings);
}

class InMemorySettingsRepository implements SettingsRepository {
  AppSettingsModel _settings = const AppSettingsModel();

  @override
  Future<AppSettingsModel> getSettings() async {
    return _settings;
  }

  @override
  Future<void> saveSettings(AppSettingsModel settings) async {
    _settings = settings;
  }
}
