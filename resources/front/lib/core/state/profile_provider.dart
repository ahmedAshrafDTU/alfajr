import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class ProfileProvider extends ChangeNotifier {
  static const String _profilesKey = 'alfajr_profiles';
  static const String _activeProfileIdKey = 'alfajr_active_profile_id';

  List<UserProfile> _profiles = [];
  UserProfile? _activeProfile;

  List<UserProfile> get profiles => _profiles;
  UserProfile? get activeProfile => _activeProfile;

  bool get hasProfiles => _profiles.isNotEmpty;
  bool get isKidsMode => _activeProfile?.ageGroup == AgeGroup.kids;
  bool get isTeenMode => _activeProfile?.ageGroup == AgeGroup.teen;
  bool get isAdultMode => _activeProfile?.ageGroup == AgeGroup.adult;
  bool get isElderlyMode => _activeProfile?.ageGroup == AgeGroup.elderly;

  ProfileProvider() {
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final profilesJson = prefs.getStringList(_profilesKey);
      if (profilesJson != null) {
        _profiles = profilesJson
            .map((jsonStr) => UserProfile.fromJson(jsonDecode(jsonStr)))
            .toList();
      }

      final activeId = prefs.getString(_activeProfileIdKey);
      if (activeId != null && _profiles.isNotEmpty) {
        _activeProfile = _profiles.cast<UserProfile?>().firstWhere(
            (p) => p?.id == activeId, 
            orElse: () => _profiles.first);
      } else if (_profiles.isNotEmpty) {
        _activeProfile = _profiles.first;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading profiles: $e');
    }
  }

  Future<void> addProfile(UserProfile profile) async {
    _profiles.add(profile);
    await _saveProfiles();
    
    if (_activeProfile == null) {
      await switchProfile(profile.id);
    } else {
      notifyListeners();
    }
  }

  Future<void> switchProfile(String id) async {
    final profile = _profiles.cast<UserProfile?>().firstWhere(
      (p) => p?.id == id,
      orElse: () => null,
    );
    
    if (profile != null) {
      _activeProfile = profile;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activeProfileIdKey, id);
      notifyListeners();
    }
  }

  Future<void> _saveProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final profilesJson = _profiles.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_profilesKey, profilesJson);
  }
}
