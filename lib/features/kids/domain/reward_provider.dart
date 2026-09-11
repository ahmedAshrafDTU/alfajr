import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RewardProvider extends ChangeNotifier {
  static const String _starsKeyPrefix = 'alfajr_stars_';
  
  int _currentStars = 0;
  final String userId;

  int get currentStars => _currentStars;

  RewardProvider(this.userId) {
    _loadStars();
  }

  Future<void> _loadStars() async {
    final prefs = await SharedPreferences.getInstance();
    _currentStars = prefs.getInt('$_starsKeyPrefix$userId') ?? 0;
    notifyListeners();
  }

  Future<void> addStars(int amount) async {
    _currentStars += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_starsKeyPrefix$userId', _currentStars);
    notifyListeners();
  }
}
