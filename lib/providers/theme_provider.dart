import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = true; // Default to dark mode for futuristic feel

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveTheme();
    notifyListeners();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? true;
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  // Futuristic Dark Theme
  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0B0F19), // Deep Space Blue
      primaryColor: const Color(0xFF00F0FF), // Neon Cyan
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF00F0FF),
        secondary: Color(0xFFBC13FE), // Neon Purple
        surface: Color(0xFF1A1F2E),
        background: Color(0xFF0B0F19),
        error: Color(0xFFFF2B2B),
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1A1F2E).withOpacity(0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        shadowColor: const Color(0xFF00F0FF).withOpacity(0.1),
      ),
    );
  }

  // Modern Light Theme
  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      primaryColor: const Color(0xFF2962FF),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF2962FF),
        secondary: Color(0xFF6200EA),
        surface: Colors.white,
        background: Color(0xFFF5F7FA),
        error: Color(0xFFFF2B2B),
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: const Color(0xFF1A1F2E),
        displayColor: const Color(0xFF1A1F2E),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF1A1F2E)),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 5,
        shadowColor: Colors.black.withOpacity(0.05),
      ),
    );
  }
}
