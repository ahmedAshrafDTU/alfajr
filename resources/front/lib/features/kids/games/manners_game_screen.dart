import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/reward_provider.dart';
import '../../../../core/theme/app_colors.dart';

class MannersGameScreen extends StatefulWidget {
  const MannersGameScreen({super.key});

  @override
  State<MannersGameScreen> createState() => _MannersGameScreenState();
}

class _MannersGameScreenState extends State<MannersGameScreen> {
  final List<Map<String, dynamic>> _questions = [
    {
      'scenario': 'ماذا تقول قبل أن تبدأ في الأكل؟',
      'icon': Icons.restaurant,
      'options': ['الحمد لله', 'بسم الله', 'الله أكبر', 'سبحان الله'],
      'answer': 'بسم الله',
    },
    {
      'scenario': 'ماذا تقول عندما تعطس؟',
      'icon': Icons.sick,
      'options': ['استغفر الله', 'بسم الله', 'الحمد لله', 'لا إله إلا الله'],
      'answer': 'الحمد لله',
    },
    {
      'scenario': 'ماذا تقول عندما تدخل المنزل؟',
      'icon': Icons.home,
      'options': ['السلام عليكم', 'إلى اللقاء', 'تصبح على خير', 'أهلاً وسهلاً'],
      'answer': 'السلام عليكم',
    },
    {
      'scenario': 'عندما تفعل شيئاً خاطئاً، ماذا تقول؟',
      'icon': Icons.error,
      'options': ['شكراً', 'أستغفر الله', 'الحمد لله', 'لا بأس'],
      'answer': 'أستغفر الله',
    },
  ];

  int _currentIndex = 0;
  int _score = 0;
  bool _showFeedback = false;
  bool _lastAnswerCorrect = false;

  void _answerQuestion(String selectedOption) {
    if (_showFeedback) return;

    final isCorrect = selectedOption == _questions[_currentIndex]['answer'];
    setState(() {
      _lastAnswerCorrect = isCorrect;
      _showFeedback = true;
      if (isCorrect) _score++;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _showFeedback = false;
        if (_currentIndex < _questions.length - 1) {
          _currentIndex++;
        } else {
          _showCompletionDialog();
        }
      });
    });
  }

  void _showCompletionDialog() {
    final success = _score == _questions.length;
    if (success) {
      context.read<RewardProvider>().addStars(20);
    } else {
      context.read<RewardProvider>().addStars(5);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(success ? 'ممتاز يا بطل! 🌟' : 'نهاية اللعبة!'),
        content: Text(
          success
              ? 'لقد أجبت على كل الأسئلة بشكل صحيح! حصلت على 20 نجمة!'
              : 'أجبت على $_score من أصل ${_questions.length}. حصلت على 5 نجوم كمكافأة، حاول مرة أخرى لتصل للعلامة الكاملة.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // go back
            },
            child: const Text('إنهاء'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('لعبة الآداب الإسلامية'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'السؤال ${_currentIndex + 1} من ${_questions.length}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textLightSecondary),
            ),
            const SizedBox(height: 24),
            Icon(question['icon'], size: 80, color: AppColors.primary),
            const SizedBox(height: 24),
            Text(
              question['scenario'],
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            if (_showFeedback)
              AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 300),
                child: Column(
                  children: [
                    Icon(
                      _lastAnswerCorrect ? Icons.check_circle : Icons.cancel,
                      color: _lastAnswerCorrect ? Colors.green : Colors.red,
                      size: 64,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _lastAnswerCorrect ? 'إجابة صحيحة! أحسنت' : 'إجابة خاطئة، الإجابة الصحيحة هي: ${question['answer']}',
                      style: TextStyle(
                        fontSize: 18,
                        color: _lastAnswerCorrect ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.5,
                  children: (question['options'] as List<String>).map((option) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => _answerQuestion(option),
                      child: Text(option, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
