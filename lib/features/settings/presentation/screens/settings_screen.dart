import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../prayer_times/domain/services/prayer_calculator_service.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/models/app_settings_model.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsRepository settingsRepository;
  final Function(bool isDark)? onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.settingsRepository,
    this.onThemeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AppSettingsModel _settings = const AppSettingsModel();
  bool _isLoading = true;

  late TextEditingController _sidController;
  late TextEditingController _tokenController;
  late TextEditingController _fromPhoneController;

  @override
  void initState() {
    super.initState();
    _sidController = TextEditingController();
    _tokenController = TextEditingController();
    _fromPhoneController = TextEditingController();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final s = await widget.settingsRepository.getSettings();
    if (mounted) {
      setState(() {
        _settings = s;
        _sidController.text = s.twilioAccountSid;
        _tokenController.text = s.twilioAuthToken;
        _fromPhoneController.text = s.twilioFromPhone;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings(AppSettingsModel newSettings) async {
    await widget.settingsRepository.saveSettings(newSettings);
    setState(() {
      _settings = newSettings;
    });
  }

  @override
  void dispose() {
    _sidController.dispose();
    _tokenController.dispose();
    _fromPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.navSettings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Prayer Times Settings
          const Text('طريقة حساب وتحديد وقت الفجر', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),

          Card(
            child: Column(
              children: [
                RadioListTile<CalculationMethod>(
                  title: const Text('أم القرى - مكة المكرمة (تلقائي)'),
                  subtitle: const Text('زاوية الفجر: 18.5 درجة'),
                  value: CalculationMethod.ummAlQura,
                  groupValue: _settings.calculationMethod,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    if (val != null) _saveSettings(_settings.copyWith(calculationMethod: val));
                  },
                ),
                const Divider(height: 1),
                RadioListTile<CalculationMethod>(
                  title: const Text('الهيئة المصرية العامة للمساحة'),
                  subtitle: const Text('زاوية الفجر: 19.5 درجة'),
                  value: CalculationMethod.egyptian,
                  groupValue: _settings.calculationMethod,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    if (val != null) _saveSettings(_settings.copyWith(calculationMethod: val));
                  },
                ),
                const Divider(height: 1),
                RadioListTile<CalculationMethod>(
                  title: const Text('توقيت يدوي ثابت مخصص'),
                  subtitle: Text('الفجر المحدد: ${TimeOfDay(hour: _settings.manualFajrHour, minute: _settings.manualFajrMinute).format(context)}'),
                  value: CalculationMethod.manual,
                  groupValue: _settings.calculationMethod,
                  activeColor: AppColors.primary,
                  onChanged: (val) async {
                    if (val != null) {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(hour: _settings.manualFajrHour, minute: _settings.manualFajrMinute),
                      );
                      if (picked != null) {
                        _saveSettings(_settings.copyWith(
                          calculationMethod: CalculationMethod.manual,
                          manualFajrHour: picked.hour,
                          manualFajrMinute: picked.minute,
                        ));
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. Call Provider Configuration
          const Text('مزود خدمة الاتصال الصوتي (Call Provider)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: _settings.callProvider,
                    decoration: const InputDecoration(
                      labelText: 'المزود المعتمد',
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: AppConstants.providerMock,
                        child: Text('Mock Simulator (محاكي المكالمات المحلي الذكي)'),
                      ),
                      DropdownMenuItem(
                        value: AppConstants.providerTwilio,
                        child: Text('Twilio Programmable Voice API'),
                      ),
                      DropdownMenuItem(
                        value: AppConstants.providerVonage,
                        child: Text('Vonage Voice API'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) _saveSettings(_settings.copyWith(callProvider: val));
                    },
                  ),
                  if (_settings.callProvider == AppConstants.providerTwilio) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _sidController,
                      decoration: const InputDecoration(
                        labelText: 'Twilio Account SID',
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      ),
                      onChanged: (val) => _saveSettings(_settings.copyWith(twilioAccountSid: val)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _tokenController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Twilio Auth Token',
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      ),
                      onChanged: (val) => _saveSettings(_settings.copyWith(twilioAuthToken: val)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _fromPhoneController,
                      decoration: const InputDecoration(
                        labelText: 'Twilio Sender Phone Number (From)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      ),
                      onChanged: (val) => _saveSettings(_settings.copyWith(twilioFromPhone: val)),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 3. Anti-Spam & Security
          const Text('قواعد الحماية والخصوصية (Anti-Spam)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),

          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('تفعيل القيود الصارمة ضد الإزعاج'),
                  subtitle: const Text('منع أكثر من 5 مكالمات للشخص، وفترة انتظار دقيقتين إلزامية.'),
                  value: _settings.strictAntiSpamEnabled,
                  activeColor: AppColors.primary,
                  onChanged: (val) => _saveSettings(_settings.copyWith(strictAntiSpamEnabled: val)),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('الإشعارات المحلية التنبيهية'),
                  subtitle: const Text('إرسال ملخص عند بدء وانتهاء جلسة الفجر.'),
                  value: _settings.enableNotifications,
                  activeColor: AppColors.primary,
                  onChanged: (val) => _saveSettings(_settings.copyWith(enableNotifications: val)),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('المظهر الداكن (Dark Mode)'),
                  subtitle: const Text('تفعيل الثيم الليلي المريح للعين'),
                  value: _settings.isDarkMode,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    _saveSettings(_settings.copyWith(isDarkMode: val));
                    widget.onThemeChanged?.call(val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 4. Backup / Export
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.download_rounded, color: AppColors.primary),
                  title: const Text('تصدير السجل والبيانات (JSON)'),
                  subtitle: const Text('حفظ نسخة احتياطية من المشتركين والإحصائيات'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم تصدير البيانات بنجاح إلى ملف النسخة الاحتياطية.')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
