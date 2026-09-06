import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/arabic_date_formatter.dart';
import '../../data/repositories/user_repository.dart';
import '../../domain/models/user_model.dart';
import '../../domain/models/user_status.dart';
import '../widgets/user_status_badge.dart';
import 'add_edit_user_screen.dart';

class UserDetailScreen extends StatefulWidget {
  final UserModel user;
  final UserRepository userRepository;
  final Function(UserModel updatedUser)? onUserUpdated;

  const UserDetailScreen({
    super.key,
    required this.user,
    required this.userRepository,
    this.onUserUpdated,
  });

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  late UserModel _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  Future<void> _updateUser(UserModel updated) async {
    await widget.userRepository.saveUser(updated);
    setState(() {
      _user = updated;
    });
    widget.onUserUpdated?.call(updated);
  }

  Future<void> _optOutUser() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد إلغاء الاشتراك'),
        content: Text('هل أنت متأكد من إلغاء اشتراك ${_user.name} نهائياً؟ لن يتلقى أي مكالمات بعد الآن.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusNoAnswer),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('تأكيد الإلغاء'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final updated = _user.copyWith(
        isOptedIn: false,
        status: UserStatus.optedOut,
        optedOutAt: DateTime.now(),
      );
      await _updateUser(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إلغاء الاشتراك بنجاح.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_user.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'تعديل البيانات',
            onPressed: () async {
              final result = await Navigator.of(context).push<UserModel>(
                MaterialPageRoute(
                  builder: (_) => AddEditUserScreen(
                    user: _user,
                    userRepository: widget.userRepository,
                  ),
                ),
              );
              if (result != null) {
                _updateUser(result);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Profile Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: _user.status.color.withOpacity(0.2),
                      child: Text(
                        _user.name.isNotEmpty ? _user.name[0] : '؟',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _user.status.color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _user.name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _user.phone,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          UserStatusBadge(status: _user.status),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Call & Session Statistics
            const Text(
              'بيانات الجلسة الحالية',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow('الأولوية', _user.priority == 1 ? 'أولوية عالية ⭐' : 'عادية'),
                    const Divider(),
                    _buildInfoRow('عدد المحاولات اليوم', '${_user.retryCount}'),
                    const Divider(),
                    _buildInfoRow('عدد الغفوات المستخدمة', '${_user.snoozeCount}'),
                    const Divider(),
                    _buildInfoRow(
                      'آخر اتصال',
                      _user.lastCalledAt != null
                          ? ArabicDateFormatter.formatTime(_user.lastCalledAt!)
                          : 'لم يتم الاتصال بعد',
                    ),
                    const Divider(),
                    _buildInfoRow(
                      'وقت الاستجابة / الرد',
                      _user.answeredAt != null
                          ? ArabicDateFormatter.formatTime(_user.answeredAt!)
                          : 'لا يوجد',
                    ),
                    const Divider(),
                    _buildInfoRow(
                      'وقت تأكيد الصلاة',
                      _user.prayedAt != null
                          ? ArabicDateFormatter.formatTime(_user.prayedAt!)
                          : 'لم تؤكد بعد',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Preferences & Controls
            const Text(
              'التحكم والتفضيلات',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('تفعيل الإيقاظ التلقائي'),
                    subtitle: const Text('استقبال مكالمات الفجر'),
                    value: _user.isWakeUpEnabled,
                    onChanged: (val) => _updateUser(_user.copyWith(isWakeUpEnabled: val)),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('تفعيل متابعة أداء الصلاة (Follow-up)'),
                    subtitle: const Text('الاتصال للسؤال "هل صليت الفجر؟"'),
                    value: _user.isFollowUpEnabled,
                    onChanged: (val) => _updateUser(_user.copyWith(isFollowUpEnabled: val)),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('إيقاف التنبيهات اليوم فقط (Pause Today)'),
                    subtitle: const Text('تخطي جلسة فجر اليوم'),
                    value: _user.isPausedToday,
                    onChanged: (val) => _updateUser(_user.copyWith(isPausedToday: val)),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('وضع الإجازة (Vacation Mode)'),
                    subtitle: const Text('إيقاف مؤقت حتى يتم تعطيل الوضع'),
                    value: _user.isVacationMode,
                    onChanged: (val) => _updateUser(_user.copyWith(isVacationMode: val)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Privacy & Consent Section
            Card(
              color: Colors.red.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.red.withOpacity(0.3)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.privacy_tip_rounded, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'الخصوصية وإلغاء الاشتراك',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _user.isOptedIn
                          ? 'المستخدم مشترك وموافق على تلقي الاتصالات.'
                          : 'المستخدم قام بإلغاء الاشتراك (Opted-Out).',
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    if (_user.isOptedIn)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _optOutUser,
                          icon: const Icon(Icons.person_off_rounded, color: Colors.red),
                          label: const Text(
                            AppStrings.optOutButton,
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _updateUser(_user.copyWith(
                              isOptedIn: true,
                              status: UserStatus.pending,
                              optedInAt: DateTime.now(),
                            ));
                          },
                          icon: const Icon(Icons.check_circle_rounded),
                          label: const Text('إعادة تفعيل الاشتراك والموافقة'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
