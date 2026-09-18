import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/state/profile_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/reward_provider.dart';
import '../games/wudu_game_screen.dart';
import '../games/salah_game_screen.dart';
import '../games/manners_game_screen.dart';
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
        backgroundColor: AppColors.lightBackground,
        appBar: AppBar(
          title: Text('مرحباً، ${user.name}! 🌟', style: const TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: [
            Consumer<RewardProvider>(
              builder: (context, reward, child) => Padding(
                padding: const EdgeInsets.only(left: 16.0), // Arabic RTL
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '⭐ ${reward.currentStars}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
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
            _buildGameCard(context, 'لعبة الوضوء 💧', Icons.wash, Colors.lightBlue, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => Provider.value(
                value: context.read<RewardProvider>(),
                child: const WuduGameScreen(),
              )));
            }),
            _buildGameCard(context, 'خطوات الصلاة 🕋', Icons.mosque, AppColors.primary, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => Provider.value(
                value: context.read<RewardProvider>(),
                child: const SalahGameScreen(),
              )));
            }),
            _buildGameCard(context, 'الآداب الإسلامية 🌟', Icons.volunteer_activism, Colors.teal, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => Provider.value(
                value: context.read<RewardProvider>(),
                child: const MannersGameScreen(),
              )));
            }),
            _buildGameCard(context, 'مسار التعلم 🎓', Icons.school, Colors.purple, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LearningPathScreen()));
            }),
            _buildGameCard(context, 'قصص الأنبياء 👑', Icons.auto_stories, Colors.deepOrange, () {
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: Colors.white),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

