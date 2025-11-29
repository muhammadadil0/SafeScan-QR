import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/browser_history_item.dart';
import '../models/form_data_item.dart';
import '../models/password_entry.dart';

class BrowserTrackingService {
  static const String _historyKey = 'browser_history';
  static const String _formDataKey = 'form_data';
  static const String _passwordsKey = 'saved_passwords';

  // Save browsing history
  Future<void> saveHistory(BrowserHistoryItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_historyKey);
    
    List<BrowserHistoryItem> history = [];
    if (historyJson != null) {
      final List<dynamic> decoded = jsonDecode(historyJson);
      history = decoded.map((e) => BrowserHistoryItem.fromJson(e)).toList();
    }

    // Check if URL already exists
    final existingIndex = history.indexWhere((h) => h.url == item.url);
    if (existingIndex != -1) {
      // Update existing entry
      history[existingIndex] = history[existingIndex].copyWith(
        visitCount: history[existingIndex].visitCount + 1,
        timestamp: DateTime.now(),
        timeSpent: history[existingIndex].timeSpent + item.timeSpent,
      );
    } else {
      // Add new entry
      history.insert(0, item);
    }

    // Keep only last 500 entries
    if (history.length > 500) {
      history = history.sublist(0, 500);
    }

    await prefs.setString(
      _historyKey,
      jsonEncode(history.map((e) => e.toJson()).toList()),
    );
  }

  // Get browsing history
  Future<List<BrowserHistoryItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_historyKey);
    
    if (historyJson == null) return [];
    
    final List<dynamic> decoded = jsonDecode(historyJson);
    return decoded.map((e) => BrowserHistoryItem.fromJson(e)).toList();
  }

  // Save form data
  Future<void> saveFormData(FormDataItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final formDataJson = prefs.getString(_formDataKey);
    
    List<FormDataItem> formData = [];
    if (formDataJson != null) {
      final List<dynamic> decoded = jsonDecode(formDataJson);
      formData = decoded.map((e) => FormDataItem.fromJson(e)).toList();
    }

    formData.insert(0, item);

    // Keep only last 200 entries
    if (formData.length > 200) {
      formData = formData.sublist(0, 200);
    }

    await prefs.setString(
      _formDataKey,
      jsonEncode(formData.map((e) => e.toJson()).toList()),
    );
  }

  // Get form data
  Future<List<FormDataItem>> getFormData() async {
    final prefs = await SharedPreferences.getInstance();
    final formDataJson = prefs.getString(_formDataKey);
    
    if (formDataJson == null) return [];
    
    final List<dynamic> decoded = jsonDecode(formDataJson);
    return decoded.map((e) => FormDataItem.fromJson(e)).toList();
  }

  // Save password
  Future<void> savePassword(PasswordEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final passwordsJson = prefs.getString(_passwordsKey);
    
    List<PasswordEntry> passwords = [];
    if (passwordsJson != null) {
      final List<dynamic> decoded = jsonDecode(passwordsJson);
      passwords = decoded.map((e) => PasswordEntry.fromJson(e)).toList();
    }

    // Check if password for this domain/username already exists
    final existingIndex = passwords.indexWhere(
      (p) => p.domain == entry.domain && p.username == entry.username,
    );

    if (existingIndex != -1) {
      // Update existing password
      passwords[existingIndex] = entry.copyWith(lastUsed: DateTime.now());
    } else {
      // Add new password
      passwords.insert(0, entry);
    }

    await prefs.setString(
      _passwordsKey,
      jsonEncode(passwords.map((e) => e.toJson()).toList()),
    );
  }

  // Get saved passwords
  Future<List<PasswordEntry>> getPasswords() async {
    final prefs = await SharedPreferences.getInstance();
    final passwordsJson = prefs.getString(_passwordsKey);
    
    if (passwordsJson == null) return [];
    
    final List<dynamic> decoded = jsonDecode(passwordsJson);
    return decoded.map((e) => PasswordEntry.fromJson(e)).toList();
  }

  // Get password for specific domain
  Future<PasswordEntry?> getPasswordForDomain(String domain, String username) async {
    final passwords = await getPasswords();
    try {
      return passwords.firstWhere(
        (p) => p.domain == domain && p.username == username,
      );
    } catch (e) {
      return null;
    }
  }

  // Clear all history
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  // Clear all form data
  Future<void> clearFormData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_formDataKey);
  }

  // Clear all passwords
  Future<void> clearPasswords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_passwordsKey);
  }

  // Get analytics
  Future<Map<String, dynamic>> getAnalytics() async {
    final history = await getHistory();
    final formData = await getFormData();
    final passwords = await getPasswords();

    // Calculate total time spent
    final totalTimeSpent = history.fold<Duration>(
      Duration.zero,
      (sum, item) => sum + item.timeSpent,
    );

    // Get most visited sites
    final sortedByVisits = List<BrowserHistoryItem>.from(history)
      ..sort((a, b) => b.visitCount.compareTo(a.visitCount));
    final topSites = sortedByVisits.take(5).toList();

    // Get domains
    final domains = history.map((h) {
      try {
        return Uri.parse(h.url).host;
      } catch (e) {
        return 'Unknown';
      }
    }).toSet().toList();

    return {
      'totalVisits': history.fold<int>(0, (sum, item) => sum + item.visitCount),
      'uniqueSites': history.length,
      'totalTimeSpent': totalTimeSpent.inMinutes,
      'formsFilled': formData.length,
      'passwordsSaved': passwords.length,
      'topSites': topSites,
      'domains': domains.length,
    };
  }
}
