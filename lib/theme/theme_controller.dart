import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class ThemeProvider with ChangeNotifier {
  static const _key = 'isDarkMode';
  final GetStorage _storage = GetStorage();
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() {
    _isDarkMode = _storage.read(_key) ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _storage.write(_key, _isDarkMode);
    notifyListeners();
  }
}
