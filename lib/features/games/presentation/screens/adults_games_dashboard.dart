import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'seerah_quiz_screen.dart';
import 'quran_trivia_screen.dart';

class AdultsGamesDashboard extends StatelessWidget {
  const AdultsGamesDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الألعاب التثقيفية'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'اختر التحدي',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'اختبر معلوماتك الدينية وزد من ثقافتك الإسلامية',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textLightSecondary,
                  ),
            ),
            const SizedBox(height: 32),
            _buildGameCard(
              context: context,
              title: 'رحلة السيرة النبوية',
              description: 'اختبر معلوماتك عن حياة النبي محمد ﷺ وأحداث السيرة',
              icon: Icons.map_rounded,
              color: const Color(0xFF0C4A34), // Deep Emerald
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SeerahQuizScreen()));
              },
            ),
            const SizedBox(height: 20),
            _buildGameCard(
              context: context,
              title: 'تحدي القرآن الكريم',
              description: 'أسئلة حول السور، معاني الكلمات، والمعلومات القرآنية',
              icon: Icons.menu_book_rounded,
              color: const Color(0xFF137351),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const QuranTriviaScreen()));
              },
            ),
            const SizedBox(height: 20),
            _buildGameCard(
              context: context,
              title: 'اختبارات الفقه',
              description: 'مواقف فقهية يومية (قريباً)',
              icon: Icons.balance_rounded,
              color: Colors.grey.shade600,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('قريباً إن شاء الله!')));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.8)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: Colors.white),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
