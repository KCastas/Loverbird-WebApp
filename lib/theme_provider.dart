import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Define different themes
enum AppTheme { gothic, cute, goofy }

class ThemeProvider extends ChangeNotifier {
  AppTheme _currentTheme = AppTheme.cute; // Default theme

  ThemeProvider() {
    _loadTheme();
  }

  AppTheme get currentTheme => _currentTheme;

  ThemeData get themeData {
    switch (_currentTheme) {
      case AppTheme.gothic:
        return ThemeData.dark();
      case AppTheme.goofy:
        return ThemeData(
          primaryColor: Colors.yellow,
          scaffoldBackgroundColor: Colors.orange,
          textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.brown)),
          appBarTheme: const AppBarTheme(backgroundColor: Colors.pink, foregroundColor: Colors.black),
        );
      case AppTheme.cute:
      default:
        return ThemeData(
          primaryColor: Colors.pink,
          scaffoldBackgroundColor: Colors.white,
          textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black)),
          appBarTheme: const AppBarTheme(backgroundColor: Colors.pinkAccent, foregroundColor: Colors.white),
        );
    }
  }

  void setTheme(AppTheme theme) async {
    _currentTheme = theme;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedTheme', theme.toString());
  }

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedTheme = prefs.getString('selectedTheme');

    if (savedTheme != null) {
      _currentTheme = AppTheme.values.firstWhere(
        (theme) => theme.toString() == savedTheme,
        orElse: () => AppTheme.cute,
      );
    }

    notifyListeners();
  }
}
