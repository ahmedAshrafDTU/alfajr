import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/repositories/group_repository.dart';
import '../../domain/models/group_model.dart';
import '../../domain/models/wake_up_config.dart';

class AddEditGroupScreen extends StatefulWidget {
  final GroupModel? group;
  final GroupRepository groupRepository;

  const AddEditGroupScreen({
    super.key,
    this.group,
    required this.groupRepository,
  });

  @override
  State<AddEditGroupScreen> createState() => _AddEditGroupScreenState();
}

class _AddEditGroupScreenState extends State<AddEditGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  int _retryDelay = 3;
  int _maxRetries = 2;
  int _followUpDelay = 10;
  int _colorValue = 0xFF0D5C3A;

  final List<int> _availableColors = [
    0xFF0D5C3A, // Emerald Green
    0xFFD4AF37, // Gold
    0xFF3B82F6, // Blue
    0xFF8B5CF6, // Purple
    0xFFF97316, // Orange
    0xFF10B981, // Mint
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.group?.name ?? '');
    _descController = TextEditingController(text: widget.group?.description ?? '');
    _retryDelay = widget.group?.config.retryDelayMinutes ?? 3;
    _maxRetries = widget.group?.config.maxRetries ?? 2;
    _followUpDelay = widget.group?.config.prayerFollowUpDelayMinutes ?? 10;
    _colorValue = widget.group?.colorValue ?? 0xFF0D5C3A;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final groupToSave = GroupModel(
      id: widget.group?.id ?? 'grp_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      colorValue: _colorValue,
      isEnabled: widget.group?.isEnabled ?? true,
      config: WakeUpConfig(
        retryDelayMinutes: _retryDelay,
        maxRetries: _maxRetries,
        prayerFollowUpDelayMinutes: _followUpDelay,
      ),
      userIds: widget.group?.userIds ?? [],
      createdAt: widget.group?.createdAt ?? DateTime.now(),
    );

    await widget.groupRepository.saveGroup(groupToSave);
    if (mounted) {
      Navigator.of(context).pop(groupToSave);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.group != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'تعديل بيانات المجموعة' : 'إنشاء مجموعة جديدة'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'اسم المجموعة *',
                prefixIcon: Icon(Icons.group_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'يرجى إدخال اسم المجموعة' : null,
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'وصف المجموعة (اختياري)',
                prefixIcon: Icon(Icons.description_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
            ),
            const SizedBox(height: 16),

            // Color Selector
            const Text('لون تمييز المجموعة', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _availableColors.map((colorVal) {
                final isSelected = _colorValue == colorVal;
                return GestureDetector(
                  onTap: () => setState(() => _colorValue = colorVal),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Color(colorVal),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: Color(colorVal).withOpacity(0.6), blurRadius: 8)]
                          : null,
                    ),
                    child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Group Scheduling Config
            const Text('إعدادات الإيقاظ والمتابعة للمجموعة', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('مهلة إعادة المحاولة:'),
                        Text('$_retryDelay دقائق', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Slider(
                      value: _retryDelay.toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: '$_retryDelay د',
                      activeColor: AppColors.primary,
                      onChanged: (val) => setState(() => _retryDelay = val.toInt()),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('الحد الأقصى للمحاولات:'),
                        Text('$_maxRetries محاولات', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Slider(
                      value: _maxRetries.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: '$_maxRetries',
                      activeColor: AppColors.primary,
                      onChanged: (val) => setState(() => _maxRetries = val.toInt()),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('مهلة متابعة الصلاة (Follow-up):'),
                        Text('$_followUpDelay دقائق', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Slider(
                      value: _followUpDelay.toDouble(),
                      min: 5,
                      max: 20,
                      divisions: 15,
                      label: '$_followUpDelay د',
                      activeColor: AppColors.primary,
                      onChanged: (val) => setState(() => _followUpDelay = val.toInt()),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check_circle_rounded),
              label: Text(isEditing ? 'حفظ التعديلات' : 'إنشاء المجموعة'),
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
