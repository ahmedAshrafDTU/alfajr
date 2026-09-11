import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/reward_provider.dart';

class WuduGameScreen extends StatefulWidget {
  const WuduGameScreen({Key? key}) : super(key: key);

  @override
  State<WuduGameScreen> createState() => _WuduGameScreenState();
}

class _WuduGameScreenState extends State<WuduGameScreen> {
  final List<String> _wuduSteps = [
    'Say Bismillah',
    'Wash hands (3 times)',
    'Rinse mouth (3 times)',
    'Clean nose (3 times)',
    'Wash face (3 times)',
    'Wash arms to elbows (3 times)',
    'Wipe head',
    'Wipe ears',
    'Wash feet to ankles (3 times)',
  ];

  int _currentStepIndex = 0;
  bool _isCompleted = false;

  void _nextStep() {
    if (_currentStepIndex < _wuduSteps.length - 1) {
      setState(() {
        _currentStepIndex++;
      });
    } else {
      setState(() {
        _isCompleted = true;
      });
      // Award stars!
      context.read<RewardProvider>().addStars(10);
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('MashaAllah! 🌟'),
        content: const Text('You learned how to make Wudu! You earned 10 stars!'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close game
            },
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Learn Wudu')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Step ${_currentStepIndex + 1} of ${_wuduSteps.length}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _wuduSteps[_currentStepIndex],
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 28),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _nextStep,
                icon: const Icon(Icons.check),
                label: const Text('Done! Next Step'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
