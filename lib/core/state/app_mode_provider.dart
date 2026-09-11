import 'package:flutter/material.dart';

enum AgeMode { kids, teen, adult, elderly }

class AppModeProvider extends ChangeNotifier {
  AgeMode _currentMode = AgeMode.adult;

  AgeMode get currentMode => _currentMode;

  void setMode(AgeMode mode) {
    _currentMode = mode;
    notifyListeners();
  }

  // Helper getters for UI adaptation
  bool get isKidsMode => _currentMode == AgeMode.kids;
  bool get isElderlyMode => _currentMode == AgeMode.elderly;
  
  // Dynamic scaling for elderly mode
  double get textScaleFactor => isElderlyMode ? 1.5 : 1.0;
}
