/// Environment & Application Configuration.
/// Values can be injected at build time using `--dart-define` flags.
class AppConfig {
  static const String appName = 'الفجر - نظام الإيقاظ لصلاة الفجر';
  static const String appVersion = '1.0.0+1';

  // Environment mode: 'development', 'staging', 'production'
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'production',
  );

  static bool get isProduction => environment == 'production';

  // Backend API URL (for secure proxy call dispatch without on-device secrets)
  static const String backendBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'https://api.alfager.app/v1',
  );

  static const String backendApiKey = String.fromEnvironment(
    'BACKEND_API_KEY',
    defaultValue: '',
  );

  // Twilio Direct Integration (Optional direct client mode)
  static const String twilioAccountSid = String.fromEnvironment(
    'TWILIO_ACCOUNT_SID',
    defaultValue: '',
  );

  static const String twilioAuthToken = String.fromEnvironment(
    'TWILIO_AUTH_TOKEN',
    defaultValue: '',
  );

  static const String twilioFromNumber = String.fromEnvironment(
    'TWILIO_FROM_NUMBER',
    defaultValue: '+18005550199',
  );

  // Feature Flags
  static const bool enableLocalPersistence = bool.fromEnvironment(
    'ENABLE_PERSISTENCE',
    defaultValue: true,
  );

  static const bool enableRealTimeAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: true,
  );
}
