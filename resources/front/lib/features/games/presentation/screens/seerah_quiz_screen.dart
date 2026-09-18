import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SeerahQuizScreen extends StatefulWidget {
  const SeerahQuizScreen({super.key});

  @override
  State<SeerahQuizScreen> createState() => _SeerahQuizScreenState();
}

class _SeerahQuizScreenState extends State<SeerahQuizScreen> {
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'أين ولد النبي محمد ﷺ؟',
      'options': ['المدينة المنورة', 'مكة المكرمة', 'الطائف', 'الشام'],
      'answer': 'مكة المكرمة',
    },
    {
      'question': 'في أي غار كان يتعبد النبي ﷺ قبل البعثة؟',
      'options': ['غار ثور', 'غار حراء', 'غار أحد', 'غار النور'],
      'answer': 'غار حراء',
    },
    {
      'question': 'ما اسم أول زوجة للنبي ﷺ؟',
      'options': ['عائشة بنت أبي بكر', 'خديجة بنت خويلد', 'حفصة بنت عمر', 'أم سلمة'],
      'answer': 'خديجة بنت خويلد',
    },
    {
      'question': 'كم كان عمر النبي ﷺ عندما نزل عليه الوحي؟',
      'options': ['30 سنة', '35 سنة', '40 سنة', '50 سنة'],
      'answer': '40 سنة',
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
      if (isCorrect) _score += 10;
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('نهاية الاختبار!'),
        content: Text(
          'لقد أنهيت التحدي!\nمجموع نقاطك: $_score من ${_questions.length * 10}',
          textAlign: TextAlign.center,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // go back
            },
            child: const Text('رجوع للقائمة'),
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
        title: const Text('رحلة السيرة النبوية'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'النقاط: $_score',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _questions.length,
              backgroundColor: AppColors.lightBackground,
              color: AppColors.primary,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'السؤال ${_currentIndex + 1} من ${_questions.length}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textLightSecondary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    question['question'],
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            if (_showFeedback)
              Expanded(
                child: Center(
                  child: AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _lastAnswerCorrect ? Icons.check_circle : Icons.cancel,
                          color: _lastAnswerCorrect ? Colors.green : Colors.red,
                          size: 80,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _lastAnswerCorrect ? 'إجابة صحيحة! +10' : 'إجابة خاطئة!\nالجواب الصحيح: ${question['answer']}',
                          style: TextStyle(
                            fontSize: 20,
                            color: _lastAnswerCorrect ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: (question['options'] as List<String>).length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final option = (question['options'] as List<String>)[index];
                    return InkWell(
                      onTap: () => _answerQuestion(option),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.lightBackground,
                          border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          option,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
