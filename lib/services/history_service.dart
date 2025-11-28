import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/scan_result.dart';

class HistoryService {
  static const String _historyKey = 'scan_history';
  static const int _maxHistoryItems = 100;
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Save a scan result to history (Firebase + Local)
  Future<void> saveScan(ScanResult result) async {
    // Save to local storage
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    history.insert(0, result);
    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }
    final jsonList = history.map((scan) => scan.toJson()).toList();
    await prefs.setString(_historyKey, jsonEncode(jsonList));
    
    // Save to Firebase if user is logged in
    final user = _auth.currentUser;
    if (user != null) {
      try {
        // Save scan to user's history collection
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('scans')
            .add({
          'url': result.originalUrl,
          'status': result.status.toString().split('.').last,
          'riskScore': result.riskScore,
          'riskFactors': result.riskFactors,
          'timestamp': FieldValue.serverTimestamp(),
          'metadata': result.metadata,
        });
        
        // Update user stats
        final isSafe = result.status == SecurityStatus.safe;
        final isBlocked = result.status == SecurityStatus.dangerous;
        
        await _firestore.collection('users').doc(user.uid).update({
          'totalScans': FieldValue.increment(1),
          if (isSafe) 'safeScans': FieldValue.increment(1),
          if (isBlocked) 'blockedScans': FieldValue.increment(1),
          'lastScanAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print('Error saving to Firebase: $e');
        // Continue even if Firebase save fails
      }
    }
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

  /// Get statistics (from Firebase if logged in, otherwise local)
  Future<Map<String, int>> getStatistics() async {
    final user = _auth.currentUser;
    
    // Try to get from Firebase first
    if (user != null) {
      try {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final data = userDoc.data()!;
          return {
            'total': data['totalScans'] ?? 0,
            'safe': data['safeScans'] ?? 0,
            'blocked': data['blockedScans'] ?? 0,
            'suspicious': 0,
            'dangerous': data['blockedScans'] ?? 0,
          };
        }
      } catch (e) {
        print('Error getting Firebase stats: $e');
      }
    }
    
    // Fallback to local storage
    final history = await getHistory();
    int totalScans = history.length;
    int safeScans = history.where((s) => s.status == SecurityStatus.safe).length;
    int suspiciousScans = history.where((s) => s.status == SecurityStatus.suspicious).length;
    int dangerousScans = history.where((s) => s.status == SecurityStatus.dangerous).length;
    int blockedScans = dangerousScans;
    
    return {
      'total': totalScans,
      'safe': safeScans,
      'suspicious': suspiciousScans,
      'dangerous': dangerousScans,
      'blocked': blockedScans,
    };
  }
  
  /// Get history from Firebase
  Future<List<Map<String, dynamic>>> getFirebaseHistory() async {
    final user = _auth.currentUser;
    if (user == null) return [];
    
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('scans')
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting Firebase history: $e');
      return [];
    }
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
