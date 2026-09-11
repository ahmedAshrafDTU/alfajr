import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/state/profile_provider.dart';
import '../domain/reward_provider.dart';
import '../games/wudu_game_screen.dart';
import '../stories/stories_screen.dart';
import '../learning/learning_path_screen.dart';
import '../../users/screens/profile_selection_screen.dart';

class KidsHomeScreen extends StatelessWidget {
  const KidsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final user = profileProvider.activeProfile;

    if (user == null) return const Scaffold();

    return ChangeNotifierProvider(
      create: (_) => RewardProvider(user.id),
      child: Scaffold(
        backgroundColor: Colors.blue.shade50,
        appBar: AppBar(
          title: Text('Welcome, ${user.name}! 🌟', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.orange,
          centerTitle: true,
          actions: [
            Consumer<RewardProvider>(
              builder: (context, reward, child) => Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: Text(
                    '⭐ ${reward.currentStars}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.yellowAccent),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () {
                // Return to profile selection
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileSelectionScreen()));
              },
            ),
          ],
        ),
        body: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(16),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildGameCard(context, 'Learn Wudu 💧', Icons.wash, Colors.lightBlue, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => Provider.value(
                value: context.read<RewardProvider>(),
                child: const WuduGameScreen(),
              )));
            }),
            _buildGameCard(context, 'Let\'s Pray 🕋', Icons.mosque, Colors.green, () {}),
            _buildGameCard(context, 'Learning Path 🎓', Icons.school, Colors.purple, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LearningPathScreen()));
            }),
            _buildGameCard(context, 'Prophet Stories 👑', Icons.auto_stories, Colors.deepOrange, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const StoriesScreen()));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: color,
      child: InkWell(
        onTap: onTap,
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

