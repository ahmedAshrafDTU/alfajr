import 'package:flutter/material.dart';

class StoriesScreen extends StatelessWidget {
  const StoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prophet Stories')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStoryCard(context, 'Prophet Nuh (AS)', 'The Ark and the Flood', Colors.blue),
          _buildStoryCard(context, 'Prophet Musa (AS)', 'The Staff and the Sea', Colors.teal),
          _buildStoryCard(context, 'Prophet Yunus (AS)', 'The Whale', Colors.indigo),
        ],
      ),
    );
  }

  Widget _buildStoryCard(BuildContext context, String title, String subtitle, Color color) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(Icons.menu_book, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening $title...')),
          );
        },
      ),
    );
  }
}
