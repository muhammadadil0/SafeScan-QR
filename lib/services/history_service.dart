import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scan_result.dart';

class HistoryService {
  static const String _historyKey = 'scan_history';
  static const int _maxHistoryItems = 100;

  /// Save a scan result to history
  Future<void> saveScan(ScanResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    
    // Add new scan at the beginning
    history.insert(0, result);
    
    // Limit history size
    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }
    
    // Convert to JSON and save
    final jsonList = history.map((scan) => scan.toJson()).toList();
    await prefs.setString(_historyKey, jsonEncode(jsonList));
  }

  /// Get all scan history
  Future<List<ScanResult>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_historyKey);
    
    if (jsonString == null) return [];
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => ScanResult.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get history filtered by status
  Future<List<ScanResult>> getHistoryByStatus(SecurityStatus status) async {
    final history = await getHistory();
    return history.where((scan) => scan.status == status).toList();
  }

  /// Get history from a specific date range
  Future<List<ScanResult>> getHistoryByDateRange(DateTime start, DateTime end) async {
    final history = await getHistory();
    return history.where((scan) {
      return scan.timestamp.isAfter(start) && scan.timestamp.isBefore(end);
    }).toList();
  }

  /// Get statistics
  Future<Map<String, int>> getStatistics() async {
    final history = await getHistory();
    
    int totalScans = history.length;
    int safeScans = history.where((s) => s.status == SecurityStatus.safe).length;
    int suspiciousScans = history.where((s) => s.status == SecurityStatus.suspicious).length;
    int dangerousScans = history.where((s) => s.status == SecurityStatus.dangerous).length;
    int blockedScans = dangerousScans; // Dangerous ones are considered blocked
    
    return {
      'total': totalScans,
      'safe': safeScans,
      'suspicious': suspiciousScans,
      'dangerous': dangerousScans,
      'blocked': blockedScans,
    };
  }

  /// Clear all history
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  /// Delete a specific scan from history
  Future<void> deleteScan(ScanResult result) async {
    final history = await getHistory();
    history.removeWhere((scan) => 
      scan.originalUrl == result.originalUrl && 
      scan.timestamp == result.timestamp
    );
    
    final prefs = await SharedPreferences.getInstance();
    final jsonList = history.map((scan) => scan.toJson()).toList();
    await prefs.setString(_historyKey, jsonEncode(jsonList));
  }

  /// Report a dangerous QR (save with flag)
  Future<void> reportDangerousQR(ScanResult result, String reason) async {
    final prefs = await SharedPreferences.getInstance();
    final reportsKey = 'reported_qrs';
    final reports = prefs.getStringList(reportsKey) ?? [];
    
    final report = {
      'url': result.originalUrl,
      'reason': reason,
      'timestamp': DateTime.now().toIso8601String(),
      'riskScore': result.riskScore,
    };
    
    reports.add(jsonEncode(report));
    await prefs.setStringList(reportsKey, reports);
  }

  /// Get reported QRs
  Future<List<Map<String, dynamic>>> getReportedQRs() async {
    final prefs = await SharedPreferences.getInstance();
    final reports = prefs.getStringList('reported_qrs') ?? [];
    
    return reports.map((reportJson) {
      return Map<String, dynamic>.from(jsonDecode(reportJson));
    }).toList();
  }
}
