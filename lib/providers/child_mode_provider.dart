import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChildModeProvider extends ChangeNotifier {
  static const String _childModeKey = 'child_mode';
  bool _isChildMode = false;

  bool get isChildMode => _isChildMode;

  ChildModeProvider() {
    _loadChildMode();
  }

  Future<void> _loadChildMode() async {
    final prefs = await SharedPreferences.getInstance();
    _isChildMode = prefs.getBool(_childModeKey) ?? false;
    notifyListeners();
  }

  Future<void> toggleChildMode() async {
    _isChildMode = !_isChildMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_childModeKey, _isChildMode);
    notifyListeners();
  }

  Future<void> setChildMode(bool enabled) async {
    _isChildMode = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_childModeKey, enabled);
    notifyListeners();
  }
}
