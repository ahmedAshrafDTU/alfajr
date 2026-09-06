import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/repositories/user_repository.dart';
import '../../domain/models/user_model.dart';
import '../../domain/models/user_status.dart';

class AddEditUserScreen extends StatefulWidget {
  final UserModel? user;
  final UserRepository userRepository;

  const AddEditUserScreen({
    super.key,
    this.user,
    required this.userRepository,
  });

  @override
  State<AddEditUserScreen> createState() => _AddEditUserScreenState();
}

class _AddEditUserScreenState extends State<AddEditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _notesController;
  int _priority = 2;
  bool _isOptedIn = true;
  bool _isWakeUpEnabled = true;
  bool _isFollowUpEnabled = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _phoneController = TextEditingController(text: widget.user?.phone ?? '');
    _notesController = TextEditingController(text: widget.user?.notes ?? '');
    _priority = widget.user?.priority ?? 2;
    _isOptedIn = widget.user?.isOptedIn ?? true;
    _isWakeUpEnabled = widget.user?.isWakeUpEnabled ?? true;
    _isFollowUpEnabled = widget.user?.isFollowUpEnabled ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final userToSave = UserModel(
      id: widget.user?.id ?? 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      priority: _priority,
      isOptedIn: _isOptedIn,
      optedInAt: _isOptedIn ? (widget.user?.optedInAt ?? DateTime.now()) : null,
      isWakeUpEnabled: _isWakeUpEnabled,
      isFollowUpEnabled: _isFollowUpEnabled,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      status: widget.user?.status ?? UserStatus.pending,
      groupId: widget.user?.groupId,
    );

    await widget.userRepository.saveUser(userToSave);
    if (mounted) {
      Navigator.of(context).pop(userToSave);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.user != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'تعديل بيانات المشترك' : 'إضافة مشترك جديد'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Name Input
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'الاسم الكامل *',
                prefixIcon: Icon(Icons.person_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'يرجى إدخال الاسم' : null,
            ),
            const SizedBox(height: 16),

            // Phone Input
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              decoration: const InputDecoration(
                labelText: 'رقم الهاتف (مع مفتاح الدولة) *',
                hintText: '+966501234567',
                prefixIcon: Icon(Icons.phone_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'يرجى إدخال رقم الهاتف';
                if (!v.startsWith('+') || v.length < 8) return 'يرجى كتابة الرقم بالصيغة الدولية مثل +966...';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Priority Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('مستوى الأولوية في الاتصال', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 1, label: Text('عالية ⭐')),
                        ButtonSegment(value: 2, label: Text('عادية')),
                        ButtonSegment(value: 3, label: Text('منخفضة')),
                      ],
                      selected: {_priority},
                      onSelectionChanged: (set) => setState(() => _priority = set.first),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Consent & Opt-in Toggle
            Card(
              color: AppColors.primaryLight.withOpacity(0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: SwitchListTile(
                title: const Text(
                  'الموافقة المسبقة (Opt-in Consent)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('أقر بأن المشترك وافق على استقبال مكالمات الإيقاظ لصلاة الفجر.'),
                value: _isOptedIn,
                activeColor: AppColors.primary,
                onChanged: (val) => setState(() => _isOptedIn = val),
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'ملاحظات إضافية (اختياري)',
                prefixIcon: Icon(Icons.note_alt_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
            ),
            const SizedBox(height: 28),

            // Submit Button
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check_circle_rounded),
              label: Text(isEditing ? 'حفظ التعديلات' : 'إضافة المشترك'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
