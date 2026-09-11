import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Al-Fajr Dashboard'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPrayerCard(),
            const SizedBox(height: 16),
            _buildProgressSection('Today\'s Azkar', 0.5),
            const SizedBox(height: 16),
            _buildProgressSection('Quran Khatmah', 0.12),
            const SizedBox(height: 16),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Next Prayer',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Asr',
              style: TextStyle(fontSize: 32, color: Colors.green.shade700, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              '- 02:45:10 -',
              style: TextStyle(fontSize: 24, letterSpacing: 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(String title, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          minHeight: 10,
          backgroundColor: Colors.grey.shade300,
          color: Colors.green,
          borderRadius: BorderRadius.circular(5),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.spaceEvenly,
      children: [
        _buildActionChip('Qibla', Icons.explore),
        _buildActionChip('Dua', Icons.menu_book),
        _buildActionChip('Tasbeeh', Icons.touch_app),
        _buildActionChip('Habits', Icons.check_circle),
      ],
    );
  }

  Widget _buildActionChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
