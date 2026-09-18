import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/reward_provider.dart';
import '../../../../core/theme/app_colors.dart';

class WuduGameScreen extends StatefulWidget {
  const WuduGameScreen({super.key});

  @override
  State<WuduGameScreen> createState() => _WuduGameScreenState();
}

class _WuduGameScreenState extends State<WuduGameScreen> {
  final List<String> _wuduSteps = [
    'نقول: بسم الله',
    'غسل الكفين (٣ مرات)',
    'المضمضة (٣ مرات)',
    'الاستنشاق والاستنثار (٣ مرات)',
    'غسل الوجه (٣ مرات)',
    'غسل اليدين إلى المرفقين (٣ مرات)',
    'مسح الرأس',
    'مسح الأذنين',
    'غسل القدمين إلى الكعبين (٣ مرات)',
  ];

  int _currentStepIndex = 0;

  void _nextStep() {
    if (_currentStepIndex < _wuduSteps.length - 1) {
      setState(() {
        _currentStepIndex++;
      });
    } else {
      context.read<RewardProvider>().addStars(10);
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('ما شاء الله! 🌟'),
        content: const Text('لقد تعلمت خطوات الوضوء بشكل صحيح! حصلت على 10 نجوم!'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close game
            },
            child: const Text('إنهاء'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('لعبة الوضوء')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'الخطوة ${_currentStepIndex + 1} من ${_wuduSteps.length}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textLightSecondary),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.lightBlue.withOpacity(0.1),
                  border: Border.all(color: Colors.lightBlue, width: 2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.water_drop, size: 64, color: Colors.lightBlue),
                    const SizedBox(height: 16),
                    Text(
                      _wuduSteps[_currentStepIndex],
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: _nextStep,
                icon: const Icon(Icons.check_circle),
                label: const Text('تم! الخطوة التالية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
