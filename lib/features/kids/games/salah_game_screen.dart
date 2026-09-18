import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/reward_provider.dart';
import '../../../../core/theme/app_colors.dart';

class SalahGameScreen extends StatefulWidget {
  const SalahGameScreen({super.key});

  @override
  State<SalahGameScreen> createState() => _SalahGameScreenState();
}

class _SalahGameScreenState extends State<SalahGameScreen> {
  final List<String> _expectedSteps = [
    'تكبيرة الإحرام',
    'قراءة الفاتحة',
    'الركوع',
    'الرفع من الركوع',
    'السجود',
    'الجلوس بين السجدتين',
    'السجود الثاني',
    'التشهد',
    'التسليم',
  ];

  late List<String> _shuffledSteps;
  final List<String> _currentOrder = [];

  @override
  void initState() {
    super.initState();
    _shuffledSteps = List.from(_expectedSteps)..shuffle();
  }

  void _checkOrder() {
    if (_currentOrder.length != _expectedSteps.length) return;

    bool isCorrect = true;
    for (int i = 0; i < _expectedSteps.length; i++) {
      if (_currentOrder[i] != _expectedSteps[i]) {
        isCorrect = false;
        break;
      }
    }

    if (isCorrect) {
      context.read<RewardProvider>().addStars(20);
      _showCompletionDialog(true);
    } else {
      _showCompletionDialog(false);
    }
  }

  void _showCompletionDialog(bool success) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(success ? 'ما شاء الله! 🌟' : 'حاول مرة أخرى 🤔'),
        content: Text(
          success
              ? 'لقد رتبت خطوات الصلاة بشكل صحيح! حصلت على 20 نجمة!'
              : 'الترتيب غير صحيح، ركز وحاول مرة أخرى يا بطل.',
        ),
        actions: [
          if (!success)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _shuffledSteps.addAll(_currentOrder);
                  _currentOrder.clear();
                  _shuffledSteps.shuffle();
                });
              },
              child: const Text('إعادة المحاولة'),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (success) Navigator.pop(context);
            },
            child: Text(success ? 'إنهاء' : 'إغلاق'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لعبة خطوات الصلاة'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'اسحب الخطوات من الأسفل وضعها بالترتيب الصحيح هنا:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Expanded(
              flex: 2,
              child: DragTarget<String>(
                onAccept: (data) {
                  setState(() {
                    _currentOrder.add(data);
                    _shuffledSteps.remove(data);
                  });
                },
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
                    ),
                    child: _currentOrder.isEmpty
                        ? Center(
                            child: Text(
                              'أفلت الخطوات هنا',
                              style: TextStyle(color: Colors.grey[500], fontSize: 18),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _currentOrder.length,
                            itemBuilder: (context, index) {
                              return Card(
                                color: AppColors.primary.withOpacity(0.1),
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: AppColors.primary,
                                    child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
                                  ),
                                  title: Text(_currentOrder[index], style: const TextStyle(fontWeight: FontWeight.bold)),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        _shuffledSteps.add(_currentOrder[index]);
                                        _currentOrder.removeAt(index);
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            if (_shuffledSteps.isNotEmpty) ...[
              const Text(
                'الخطوات المتاحة:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                flex: 1,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _shuffledSteps.map((step) {
                    return Draggable<String>(
                      data: step,
                      feedback: Material(
                        color: Colors.transparent,
                        child: Chip(
                          backgroundColor: AppColors.primary,
                          label: Text(step, style: const TextStyle(color: Colors.white)),
                        ),
                      ),
                      childWhenDragging: Chip(
                        backgroundColor: Colors.grey[300],
                        label: Text(step, style: const TextStyle(color: Colors.grey)),
                      ),
                      child: Chip(
                        backgroundColor: AppColors.secondary,
                        label: Text(step, style: const TextStyle(color: AppColors.primary)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            if (_shuffledSteps.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  onPressed: _checkOrder,
                  child: const Text('تحقق من الإجابة', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
