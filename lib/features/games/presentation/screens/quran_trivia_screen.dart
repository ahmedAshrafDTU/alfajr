import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class QuranTriviaScreen extends StatefulWidget {
  const QuranTriviaScreen({super.key});

  @override
  State<QuranTriviaScreen> createState() => _QuranTriviaScreenState();
}

class _QuranTriviaScreenState extends State<QuranTriviaScreen> {
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'ما هي أطول سورة في القرآن الكريم؟',
      'options': ['البقرة', 'آل عمران', 'النساء', 'المائدة'],
      'answer': 'البقرة',
    },
    {
      'question': 'كم عدد أجزاء القرآن الكريم؟',
      'options': ['20 جزء', '30 جزء', '40 جزء', '60 جزء'],
      'answer': '30 جزء',
    },
    {
      'question': 'ما هي السورة التي تسمى عروس القرآن؟',
      'options': ['يس', 'الرحمن', 'الواقعة', 'تبارك'],
      'answer': 'الرحمن',
    },
    {
      'question': 'ما هي السورة التي لا تبدأ بـ "بسم الله الرحمن الرحيم"؟',
      'options': ['التوبة', 'الأنفال', 'يونس', 'هود'],
      'answer': 'التوبة',
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
        title: const Text('نهاية التحدي!'),
        content: Text(
          'لقد أنهيت تحدي القرآن الكريم!\nمجموع نقاطك: $_score من ${_questions.length * 10}',
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
        title: const Text('تحدي القرآن الكريم'),
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
              color: AppColors.secondary,
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
