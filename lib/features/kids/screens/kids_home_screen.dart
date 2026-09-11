import 'package:flutter/material.dart';

class KidsHomeScreen extends StatelessWidget {
  const KidsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text('My Islamic World 🌟', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildGameCard('Learn Wudu 💧', Icons.wash, Colors.lightBlue),
          _buildGameCard('Let\'s Pray 🕋', Icons.mosque, Colors.green),
          _buildGameCard('Quran Games 📖', Icons.menu_book, Colors.purple),
          _buildGameCard('Prophet Stories 👑', Icons.auto_stories, Colors.deepOrange),
        ],
      ),
    );
  }

  Widget _buildGameCard(String title, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: color,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.white),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
