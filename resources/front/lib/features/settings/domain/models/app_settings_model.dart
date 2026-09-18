import '../../../../core/constants/app_constants.dart';
import '../../../prayer_times/domain/services/prayer_calculator_service.dart';

/// App Settings Model.
class AppSettingsModel {
  final CalculationMethod calculationMethod;
  final int manualFajrHour;
  final int manualFajrMinute;
  final String callProvider;
  final String twilioAccountSid;
  final String twilioAuthToken;
  final String twilioFromPhone;
  final String webhookBaseUrl;
  final bool enableNotifications;
  final bool isDarkMode;
  final int defaultRetryDelayMinutes;
  final int defaultMaxRetries;
  final int defaultFollowUpDelayMinutes;
  final int defaultMaxSnoozeCount;
  final bool strictAntiSpamEnabled;

  const AppSettingsModel({
    this.calculationMethod = CalculationMethod.ummAlQura,
    this.manualFajrHour = 4,
    this.manualFajrMinute = 25,
    this.callProvider = AppConstants.providerMock,
    this.twilioAccountSid = '',
    this.twilioAuthToken = '',
    this.twilioFromPhone = '',
    this.webhookBaseUrl = '',
    this.enableNotifications = true,
    this.isDarkMode = false,
    this.defaultRetryDelayMinutes = AppConstants.defaultRetryDelayMinutes,
    this.defaultMaxRetries = AppConstants.defaultMaxRetries,
    this.defaultFollowUpDelayMinutes = AppConstants.defaultPrayerFollowUpMinutes,
    this.defaultMaxSnoozeCount = AppConstants.defaultMaxSnoozeCount,
    this.strictAntiSpamEnabled = true,
  });

  String get activeCallProvider => callProvider;
  String get twilioFromNumber => twilioFromPhone;

  AppSettingsModel copyWith({
    CalculationMethod? calculationMethod,
    int? manualFajrHour,
    int? manualFajrMinute,
    String? callProvider,
    String? twilioAccountSid,
    String? twilioAuthToken,
    String? twilioFromPhone,
    String? webhookBaseUrl,
    bool? enableNotifications,
    bool? isDarkMode,
    int? defaultRetryDelayMinutes,
    int? defaultMaxRetries,
    int? defaultFollowUpDelayMinutes,
    int? defaultMaxSnoozeCount,
    bool? strictAntiSpamEnabled,
  }) {
    return AppSettingsModel(
      calculationMethod: calculationMethod ?? this.calculationMethod,
      manualFajrHour: manualFajrHour ?? this.manualFajrHour,
      manualFajrMinute: manualFajrMinute ?? this.manualFajrMinute,
      callProvider: callProvider ?? this.callProvider,
      twilioAccountSid: twilioAccountSid ?? this.twilioAccountSid,
      twilioAuthToken: twilioAuthToken ?? this.twilioAuthToken,
      twilioFromPhone: twilioFromPhone ?? this.twilioFromPhone,
      webhookBaseUrl: webhookBaseUrl ?? this.webhookBaseUrl,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      defaultRetryDelayMinutes: defaultRetryDelayMinutes ?? this.defaultRetryDelayMinutes,
      defaultMaxRetries: defaultMaxRetries ?? this.defaultMaxRetries,
      defaultFollowUpDelayMinutes:
          defaultFollowUpDelayMinutes ?? this.defaultFollowUpDelayMinutes,
      defaultMaxSnoozeCount:
          defaultMaxSnoozeCount ?? this.defaultMaxSnoozeCount,
      strictAntiSpamEnabled:
          strictAntiSpamEnabled ?? this.strictAntiSpamEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calculationMethod': calculationMethod.name,
      'manualFajrHour': manualFajrHour,
      'manualFajrMinute': manualFajrMinute,
      'callProvider': callProvider,
      'twilioAccountSid': twilioAccountSid,
      'twilioAuthToken': twilioAuthToken,
      'twilioFromPhone': twilioFromPhone,
      'webhookBaseUrl': webhookBaseUrl,
      'enableNotifications': enableNotifications,
      'isDarkMode': isDarkMode,
      'defaultRetryDelayMinutes': defaultRetryDelayMinutes,
      'defaultMaxRetries': defaultMaxRetries,
      'defaultFollowUpDelayMinutes': defaultFollowUpDelayMinutes,
      'defaultMaxSnoozeCount': defaultMaxSnoozeCount,
      'strictAntiSpamEnabled': strictAntiSpamEnabled,
    };
  }

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      calculationMethod: CalculationMethod.values.firstWhere(
        (m) => m.name == json['calculationMethod'],
        orElse: () => CalculationMethod.ummAlQura,
      ),
      manualFajrHour: json['manualFajrHour'] as int? ?? 4,
      manualFajrMinute: json['manualFajrMinute'] as int? ?? 25,
      callProvider: json['callProvider'] as String? ?? AppConstants.providerMock,
      twilioAccountSid: json['twilioAccountSid'] as String? ?? '',
      twilioAuthToken: json['twilioAuthToken'] as String? ?? '',
      twilioFromPhone: json['twilioFromPhone'] as String? ?? '',
      webhookBaseUrl: json['webhookBaseUrl'] as String? ?? '',
      enableNotifications: json['enableNotifications'] as bool? ?? true,
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      defaultRetryDelayMinutes:
          json['defaultRetryDelayMinutes'] as int? ?? AppConstants.defaultRetryDelayMinutes,
      defaultMaxRetries:
          json['defaultMaxRetries'] as int? ?? AppConstants.defaultMaxRetries,
      defaultFollowUpDelayMinutes:
          json['defaultFollowUpDelayMinutes'] as int? ?? AppConstants.defaultPrayerFollowUpMinutes,
      defaultMaxSnoozeCount:
          json['defaultMaxSnoozeCount'] as int? ?? AppConstants.defaultMaxSnoozeCount,
      strictAntiSpamEnabled: json['strictAntiSpamEnabled'] as bool? ?? true,
    );
  }
}
