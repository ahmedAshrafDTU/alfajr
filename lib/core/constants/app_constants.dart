/// Global application constants and default configurations.
class AppConstants {
  // Retry & Intervals
  static const int defaultRetryDelayMinutes = 3;
  static const int defaultMaxRetries = 2;
  static const int defaultPrayerFollowUpMinutes = 10;
  static const int defaultSecondFollowUpMinutes = 5;
  static const int defaultSnoozeMinutes = 5;
  static const int defaultMaxSnoozeCount = 2;

  // Anti-Spam Constraints
  static const int maxAllowedCallsPerUserPerSession = 5;
  static const int minIntervalSecondsBetweenCalls = 120; // 2 minutes minimum
  static const int callTimeoutSeconds = 45;
  static const int sessionFajrWindowMinutes = 90; // calls only within 90 mins of Fajr

  // Storage Keys
  static const String keyUsers = 'alfager_users_v1';
  static const String keyGroups = 'alfager_groups_v1';
  static const String keySessions = 'alfager_sessions_v1';
  static const String keySettings = 'alfager_settings_v1';
  static const String keyAuthToken = 'alfager_auth_token_secure';

  // API Call Providers
  static const String providerMock = 'mock';
  static const String providerTwilio = 'twilio';
  static const String providerVonage = 'vonage';
}
