import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/state/profile_provider.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../kids/screens/kids_home_screen.dart';
// import '../../users/screens/profile_selection_screen.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    
    if (!profileProvider.hasProfiles) {
      // If we don't want cyclic imports, we just handle the profile creation elsewhere,
      // but RootScreen is usually top level.
      // We'll let ProfileSelectionScreen be the initial route.
    }

    if (profileProvider.isKidsMode) {
      return const KidsHomeScreen();
    }
    
    // Default to Adult/Teen Dashboard for now
    return const DashboardScreen();
  }
}
