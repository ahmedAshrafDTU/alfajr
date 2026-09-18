import 'package:flutter/material.dart';
import 'package:alfager/features/wird/domain/entities/wird.dart';
import 'package:alfager/features/wird/domain/repositories/wird_repository.dart';

class CreateWirdScreen extends StatefulWidget {
  final WirdRepository wirdRepository;
  final Wird? wirdToEdit;

  const CreateWirdScreen({
    super.key,
    required this.wirdRepository,
    this.wirdToEdit,
  });

  @override
  State<CreateWirdScreen> createState() => _CreateWirdScreenState();
}

class _CreateWirdScreenState extends State<CreateWirdScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late String _title;
  late String _category;
  late WirdType _type;
  late int _target;
  late String _unit;
  TimeOfDay? _reminderTime;

  @override
  void initState() {
    super.initState();
    _title = widget.wirdToEdit?.title ?? '';
    _category = widget.wirdToEdit?.category ?? 'أذكار';
    _type = widget.wirdToEdit?.type ?? WirdType.count;
    _target = widget.wirdToEdit?.target ?? 100;
    _unit = widget.wirdToEdit?.unit ?? 'مرة';
    _reminderTime = widget.wirdToEdit?.reminderTime;
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final wird = Wird(
        id: widget.wirdToEdit?.id ?? 'wird_${DateTime.now().millisecondsSinceEpoch}',
        title: _title,
        category: _category,
        type: _type,
        target: _target,
        unit: _unit,
        reminderTime: _reminderTime,
        startDate: widget.wirdToEdit?.startDate ?? DateTime.now(),
        createdAt: widget.wirdToEdit?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await widget.wirdRepository.saveWird(wird);
      
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wirdToEdit == null ? 'إضافة ورد جديد' : 'تعديل الورد'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _save,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              initialValue: _title,
              decoration: const InputDecoration(labelText: 'اسم الورد'),
              validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
              onSaved: (val) => _title = val!,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'التصنيف'),
              items: ['أذكار', 'القرآن', 'صلاة', 'أخرى']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => _category = val!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<WirdType>(
              value: _type,
              decoration: const InputDecoration(labelText: 'نوع الورد'),
              items: const [
                DropdownMenuItem(value: WirdType.count, child: Text('عدد مرات')),
                DropdownMenuItem(value: WirdType.duration, child: Text('مدة زمنية')),
                DropdownMenuItem(value: WirdType.checkbox, child: Text('قائمة مهام')),
              ],
              onChanged: (val) => setState(() => _type = val!),
            ),
            const SizedBox(height: 16),
            if (_type != WirdType.checkbox) ...[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _target.toString(),
                      decoration: const InputDecoration(labelText: 'الهدف (العدد)'),
                      keyboardType: TextInputType.number,
                      onSaved: (val) => _target = int.tryParse(val ?? '0') ?? 0,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: _unit,
                      decoration: const InputDecoration(labelText: 'الوحدة (مثال: مرة, صفحة)'),
                      onSaved: (val) => _unit = val ?? '',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            ListTile(
              title: const Text('وقت التذكير'),
              subtitle: Text(_reminderTime?.format(context) ?? 'لم يتم التحديد'),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _reminderTime ?? TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() => _reminderTime = time);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
