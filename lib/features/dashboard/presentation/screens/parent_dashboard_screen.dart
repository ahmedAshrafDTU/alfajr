import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/state/profile_provider.dart';
import '../../../../core/models/user_profile.dart';

class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final kids = profileProvider.profiles.where((p) => p.ageGroup == AgeGroup.kids).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Dashboard'),
        centerTitle: true,
      ),
      body: kids.isEmpty
          ? const Center(child: Text('No kids profiles found in the family.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: kids.length,
              itemBuilder: (context, index) {
                final kid = kids[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              child: Text(kid.name[0]),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                kid.name,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const Icon(Icons.star, color: Colors.amber, size: 28),
                            const SizedBox(width: 4),
                            // In a real app we'd load stars per kid ID from RewardProvider or SharedPreferences
                            const Text('10', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Divider(height: 30),
                        const Text('Recent Activity:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const ListTile(
                          leading: Icon(Icons.check_circle, color: Colors.green),
                          title: Text('Completed Wudu Lesson'),
                          subtitle: Text('Today at 3:00 PM'),
                        ),
                        const ListTile(
                          leading: Icon(Icons.mosque, color: Colors.blue),
                          title: Text('Prayed Dhuhr'),
                          subtitle: Text('Today at 1:15 PM'),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add_task),
                          label: const Text('Assign New Task'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 40),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
