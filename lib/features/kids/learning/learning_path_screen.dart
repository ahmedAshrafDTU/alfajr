import 'package:flutter/material.dart';

class LearningPathScreen extends StatelessWidget {
  const LearningPathScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Learning Path')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPathNode(context, 'Level 1: Arabic Letters', Icons.abc, true),
          _buildPathNode(context, 'Level 2: Harakat', Icons.translate, false),
          _buildPathNode(context, 'Level 3: Short Surahs', Icons.menu_book, false),
          _buildPathNode(context, 'Level 4: Wudu Basics', Icons.wash, false),
          _buildPathNode(context, 'Level 5: Salah Basics', Icons.mosque, false),
        ],
      ),
    );
  }

  Widget _buildPathNode(BuildContext context, String title, IconData icon, bool isUnlocked) {
    return Card(
      elevation: isUnlocked ? 4 : 1,
      color: isUnlocked ? Colors.white : Colors.grey[200],
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: isUnlocked ? Colors.green : Colors.grey,
          child: Icon(isUnlocked ? Icons.lock_open : Icons.lock, color: Colors.white),
        ),
        title: Text(
          title, 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 18,
            color: isUnlocked ? Colors.black : Colors.grey
          )
        ),
        trailing: Icon(icon, color: isUnlocked ? Colors.blue : Colors.grey, size: 32),
        onTap: isUnlocked ? () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Starting $title...')),
          );
        } : null,
      ),
    );
  }
}
