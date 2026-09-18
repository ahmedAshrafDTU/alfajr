import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/state/profile_provider.dart';
import '../../../core/models/user_profile.dart';

class ProfileSelectionScreen extends StatelessWidget {
  const ProfileSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Select Profile')),
      body: profileProvider.profiles.isEmpty
          ? _buildEmptyState(context)
          : _buildProfileList(context, profileProvider),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Welcome to Al-Fajr', style: TextStyle(fontSize: 24)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _createNewProfile(context),
            child: const Text('Create First Profile (Adult)'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => _createKidsProfile(context),
            child: const Text('Create Kids Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileList(BuildContext context, ProfileProvider provider) {
    return ListView.builder(
      itemCount: provider.profiles.length + 1,
      itemBuilder: (context, index) {
        if (index == provider.profiles.length) {
          return ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Add New Profile'),
            onTap: () => _createNewProfile(context),
          );
        }

        final profile = provider.profiles[index];
        return ListTile(
          leading: CircleAvatar(child: Text(profile.name[0])),
          title: Text(profile.name),
          subtitle: Text('${profile.ageGroup.name} Mode'),
          trailing: provider.activeProfile?.id == profile.id 
              ? const Icon(Icons.check_circle, color: Colors.green) 
              : null,
          onTap: () async {
            await provider.switchProfile(profile.id);
          },
        );
      },
    );
  }

  void _createNewProfile(BuildContext context) async {
    final newProfile = UserProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Adult User',
      ageGroup: AgeGroup.adult,
      role: UserRole.individual,
    );
    
    await context.read<ProfileProvider>().addProfile(newProfile);
  }

  void _createKidsProfile(BuildContext context) async {
    final newProfile = UserProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Kid User',
      ageGroup: AgeGroup.kids,
      role: UserRole.child,
    );
    
    await context.read<ProfileProvider>().addProfile(newProfile);
  }
}
