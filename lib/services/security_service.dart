import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/security_keywords.dart';
import '../models/scan_result.dart';
// import 'ml_service.dart'; // Temporarily disabled - TFLite compatibility issue

class SecurityService {
  // AI Model API Configuration
  // IMPORTANT: Replace with your actual IP address
  // - For Android Emulator: use '10.0.2.2'
  // - For Real Phone: use your PC's IP (e.g., '192.168.1.5')
  // - For iOS Simulator: use 'localhost' or '127.0.0.1'
  static const String AI_API_URL = "http://10.0.2.2:5001/scan";
  
  // URL Shortener domains
  static const List<String> urlShorteners = [
    'tinyurl.com', 'bit.ly', 'cut.ly', 't.co', 'goo.gl', 'ow.ly',
    'is.gd', 'buff.ly', 'adf.ly', 'short.io', 'rebrand.ly', 'cutt.ly',
    'bl.ink', 'lnkd.in', 'soo.gd', 'clicky.me', 'budurl.com'
  ];

  // Suspicious URL parameters
  static const List<String> suspiciousParams = [
    'password', 'email', 'token', 'session', 'auth', 'key',
    'login', 'user', 'pass', 'credential', 'secret', 'api_key',
    'access_token', 'refresh_token', 'otp', 'pin'
  ];

  // File extensions for apps/executables
  static const List<String> executableExtensions = [
    '.apk', '.exe', '.msi', '.dmg', '.app', '.deb', '.rpm',
    '.bat', '.sh', '.jar', '.pkg', '.run'
  ];

  /// Main analysis function with all advanced features
  Future<ScanResult> analyzeUrl(String url) async {
    List<String> risks = [];
    SecurityStatus status = SecurityStatus.safe;
    String finalUrl = url;
    int riskScore = 0; // 0-100 scale
    String contentType = 'url';
    Map<String, dynamic> metadata = {};

    // 1. Detect QR content type
    contentType = _detectContentType(url);
    metadata['contentType'] = contentType;

    // Handle non-URL content
    if (contentType != 'url') {
      return _handleNonUrlContent(url, contentType);
    }

    // 2. Basic Validation
    if (url.trim().isEmpty) {
      return ScanResult(
        originalUrl: url,
        status: SecurityStatus.dangerous,
        riskFactors: ['Empty URL'],
        riskScore: 100,
      );
    }

    // 3. Normalize URL
    String normalizedUrl = url;
    if (!url.startsWith('http')) {
      normalizedUrl = 'https://$url';
    }

    Uri? uri;
    try {
      uri = Uri.parse(normalizedUrl);
    } catch (e) {
      return ScanResult(
        originalUrl: url,
        status: SecurityStatus.dangerous,
        riskFactors: ['Invalid URL format'],
        riskScore: 100,
      );
    }

    // 4. URL Shortener Detection
    if (_isUrlShortener(uri.host)) {
      risks.add('⚠️ Shortened URL detected - Attackers often hide malicious links');
      riskScore += 25;
      status = _escalateStatus(status, SecurityStatus.suspicious);
      metadata['isShortened'] = true;
    }

    // 5. Malicious APK/File Detection
    String path = uri.path.toLowerCase();
    for (var ext in executableExtensions) {
      if (path.endsWith(ext)) {
        risks.add('🚨 Downloadable app file detected ($ext) - High Risk!');
        riskScore += 40;
        status = SecurityStatus.dangerous;
        metadata['hasExecutable'] = true;
        metadata['fileExtension'] = ext;
        break;
      }
    }

    // 6. Suspicious Parameter Detection
    List<String> foundParams = [];
    uri.queryParameters.forEach((key, value) {
      if (suspiciousParams.contains(key.toLowerCase())) {
        foundParams.add(key);
      }
    });
    if (foundParams.isNotEmpty) {
      risks.add('⚠️ Suspicious parameters: ${foundParams.join(", ")}');
      riskScore += 20;
      status = _escalateStatus(status, SecurityStatus.suspicious);
      metadata['suspiciousParams'] = foundParams;
    }

    // 7. IP Address Check
    if (_isIpAddress(uri.host)) {
      risks.add('🔴 Raw IP address instead of domain name');
      riskScore += 30;
      status = _escalateStatus(status, SecurityStatus.dangerous);
    }

    // 8. High Entropy Check
    if (_hasHighEntropy(uri.host)) {
      risks.add('⚠️ Random/generated domain name detected');
      riskScore += 15;
      status = _escalateStatus(status, SecurityStatus.suspicious);
    }

    // 9. HTTPS Check
    if (uri.scheme == 'http') {
      risks.add('🔓 Not using HTTPS (Insecure connection)');
      riskScore += 20;
      status = _escalateStatus(status, SecurityStatus.suspicious);
    }

    // 10. Phishing Keywords Check
    String lowerUrl = url.toLowerCase();
    for (var keyword in SecurityConstants.phishingKeywords) {
      if (uri.host.toLowerCase().contains(keyword)) {
        risks.add('🎣 Phishing keyword in domain: "$keyword"');
        riskScore += 25;
        status = _escalateStatus(status, SecurityStatus.suspicious);
      } else if (lowerUrl.contains(keyword)) {
        risks.add('⚠️ Sensitive keyword in URL: "$keyword"');
        riskScore += 10;
        status = _escalateStatus(status, SecurityStatus.suspicious);
      }
    }

    // 11. Suspicious Domains Check
    String domain = uri.host.toLowerCase();
    for (var suspicious in SecurityConstants.suspiciousDomains) {
      if (domain.contains(suspicious) || domain.endsWith('.$suspicious')) {
        risks.add('⚠️ Suspicious hosting/domain: "$suspicious"');
        riskScore += 15;
        status = _escalateStatus(status, SecurityStatus.suspicious);
      }
    }

    // 12. Typosquatting Detection
    if (_detectTyposquatting(domain)) {
      risks.add('🚨 Potential typosquatting detected');
      riskScore += 35;
      status = SecurityStatus.dangerous;
    }

    // 13. Long Domain Check
    if (domain.length > 50) {
      risks.add('⚠️ Extremely long domain (${domain.length} chars)');
      riskScore += 10;
      status = _escalateStatus(status, SecurityStatus.suspicious);
    }

    // 14. Non-standard Port Check
    if (uri.hasPort && uri.port != 80 && uri.port != 443) {
      risks.add('⚠️ Non-standard port: ${uri.port}');
      riskScore += 15;
      status = _escalateStatus(status, SecurityStatus.suspicious);
    }

    // 15. Subdomain Count (too many subdomains is suspicious)
    int subdomainCount = domain.split('.').length - 2;
    if (subdomainCount > 3) {
      risks.add('⚠️ Excessive subdomains ($subdomainCount levels)');
      riskScore += 10;
      status = _escalateStatus(status, SecurityStatus.suspicious);
    }

    // 16. Network Check (Redirects) - Optional, can work offline
    try {
      final response = await http.head(uri).timeout(const Duration(seconds: 4));
      
      if (response.isRedirect || response.statusCode >= 300 && response.statusCode < 400) {
        risks.add('🔄 URL redirects to another location');
        if (response.headers['location'] != null) {
          finalUrl = response.headers['location']!;
          metadata['redirectsTo'] = finalUrl;
          riskScore += 10;
          status = _escalateStatus(status, SecurityStatus.suspicious);
        }
      }
    } catch (e) {
      // Offline mode - continue without network check
      metadata['offlineMode'] = true;
    }


    // 17. AI Model Prediction (Hugging Face Transformers)
    try {
      final aiPrediction = await _callAIModel(url);
      if (aiPrediction != null) {
        metadata['aiPrediction'] = aiPrediction['label'];
        metadata['aiConfidence'] = aiPrediction['confidence'];
        metadata['aiScanTime'] = aiPrediction['scan_time_ms'];
        
        // Add AI insights to risks
        bool isSafe = aiPrediction['is_safe'] ?? false;
        double confidence = aiPrediction['confidence'] ?? 0.0;
        
        if (!isSafe) {
          // AI detected malicious
          // Set risk score based on AI confidence (if higher than current rule-based score)
          int aiRiskScore = confidence.toInt();
          if (aiRiskScore > riskScore) {
            riskScore = aiRiskScore;
          }
          
          // Force dangerous status if confidence is high
          if (confidence >= 70.0) {
            status = SecurityStatus.dangerous;
            risks.add('🤖 AI detected: Malicious URL (${confidence.toStringAsFixed(1)}% confidence)');
          } else {
            status = _escalateStatus(status, SecurityStatus.suspicious);
            risks.add('🤖 AI detected: Potentially malicious (${confidence.toStringAsFixed(1)}% confidence)');
          }
        } else if (isSafe && confidence >= 80.0) {
          risks.add('🤖 AI verified: Appears safe (${confidence.toStringAsFixed(1)}% confidence)');
        }
      }
    } catch (e) {
      // AI prediction failed - continue with rule-based only
      metadata['aiError'] = 'AI model not available: ${e.toString()}';
      print('AI Model Error: $e');
    }


    // 18. Final Risk Score Calculation
    riskScore = riskScore.clamp(0, 100);
    
    // Adjust status based on final score
    if (riskScore >= 70) {
      status = SecurityStatus.dangerous;
    } else if (riskScore >= 40) {
      status = SecurityStatus.suspicious;
    } else if (riskScore > 0) {
      status = SecurityStatus.suspicious;
    }

    // Add summary
    if (risks.isEmpty) {
      risks.add('✅ No obvious threats detected');
    }

    return ScanResult(
      originalUrl: url,
      status: status,
      riskFactors: risks,
      finalUrl: finalUrl,
      riskScore: riskScore,
      metadata: metadata,
    );
  }

  /// Detect QR content type
  String _detectContentType(String content) {
    content = content.trim();

    // WiFi format: WIFI:T:WPA;S:NetworkName;P:password;;
    if (content.toUpperCase().startsWith('WIFI:')) {
      return 'wifi';
    }

    // Email: mailto:someone@example.com
    if (content.toLowerCase().startsWith('mailto:')) {
      return 'email';
    }

    // Phone: tel:+1234567890
    if (content.toLowerCase().startsWith('tel:')) {
      return 'phone';
    }

    // SMS: sms:+1234567890
    if (content.toLowerCase().startsWith('sms:')) {
      return 'sms';
    }

    // vCard/Contact
    if (content.toUpperCase().startsWith('BEGIN:VCARD')) {
      return 'contact';
    }

    // UPI Payment (India/Pakistan)
    if (content.toLowerCase().startsWith('upi://')) {
      return 'payment';
    }

    // Geo location
    if (content.toLowerCase().startsWith('geo:')) {
      return 'location';
    }

    // Check if it looks like a URL
    if (content.contains('.') || content.contains('://')) {
      return 'url';
    }

    // Plain text
    return 'text';
  }

  /// Handle non-URL content types
  ScanResult _handleNonUrlContent(String content, String type) {
    List<String> risks = [];
    SecurityStatus status = SecurityStatus.safe;
    int riskScore = 0;

    switch (type) {
      case 'wifi':
        risks.add('📶 WiFi credentials detected');
        risks.add('⚠️ Only connect if you trust the source');
        riskScore = 30;
        status = SecurityStatus.suspicious;
        break;
      case 'email':
        risks.add('📧 Email address detected');
        risks.add('✅ Generally safe');
        break;
      case 'phone':
        risks.add('📞 Phone number detected');
        risks.add('⚠️ Verify before calling');
        riskScore = 10;
        break;
      case 'payment':
        risks.add('💳 Payment link detected');
        risks.add('⚠️ Verify recipient before paying');
        riskScore = 40;
        status = SecurityStatus.suspicious;
        break;
      case 'contact':
        risks.add('👤 Contact information detected');
        risks.add('✅ Generally safe');
        break;
      case 'text':
        risks.add('📝 Plain text content');
        risks.add('✅ Safe');
        break;
      default:
        risks.add('❓ Unknown content type');
    }

    return ScanResult(
      originalUrl: content,
      status: status,
      riskFactors: risks,
      riskScore: riskScore,
      metadata: {'contentType': type},
    );
  }

  /// Check if domain is a URL shortener
  bool _isUrlShortener(String host) {
    host = host.toLowerCase();
    return urlShorteners.any((shortener) => 
      host == shortener || host.endsWith('.$shortener')
    );
  }

  /// Detect typosquatting patterns
  bool _detectTyposquatting(String domain) {
    // Common typosquatting patterns
    final patterns = [
      RegExp(r'[a-z]00[a-z]'),      // o0 -> 00
      RegExp(r'paypa1'),             // paypal -> paypa1
      RegExp(r'faceb00k'),           // facebook -> faceb00k
      RegExp(r'g00gle'),             // google -> g00gle
      RegExp(r'amaz0n'),             // amazon -> amaz0n
      RegExp(r'micr0soft'),          // microsoft -> micr0soft
      RegExp(r'app1e'),              // apple -> app1e
      RegExp(r'netf1ix'),            // netflix -> netf1ix
    ];

    return patterns.any((pattern) => pattern.hasMatch(domain));
  }

  bool _isIpAddress(String host) {
    final parts = host.split('.');
    if (parts.length != 4) return false;
    for (final part in parts) {
      final num = int.tryParse(part);
      if (num == null || num < 0 || num > 255) return false;
    }
    return true;
  }

  bool _hasHighEntropy(String host) {
    final parts = host.split('.');
    for (var part in parts) {
      if (part.length > 12 && 
          RegExp(r'[0-9]').hasMatch(part) && 
          RegExp(r'[a-zA-Z]').hasMatch(part)) {
        return true;
      }
    }
    return false;
  }

  SecurityStatus _escalateStatus(SecurityStatus current, SecurityStatus newStatus) {
    if (current == SecurityStatus.dangerous) return current;
    if (newStatus == SecurityStatus.dangerous) return newStatus;
    if (current == SecurityStatus.suspicious) return current;
    return newStatus;
  }

  /// Get risk level text based on score
  String getRiskLevel(int score) {
    if (score >= 70) return 'High Risk';
    if (score >= 40) return 'Medium Risk';
    if (score >= 20) return 'Low Risk';
    return 'Safe';
  }

  /// Get risk color based on score
  String getRiskColor(int score) {
    if (score >= 70) return 'red';
    if (score >= 40) return 'orange';
    if (score >= 20) return 'yellow';
    return 'green';
  }

  /// Call AI Model API for malicious URL detection
  Future<Map<String, dynamic>?> _callAIModel(String url) async {
    try {
      print("🤖 Sending URL to AI model: $url");

      final response = await http.post(
        Uri.parse(AI_API_URL),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"url": url}),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        bool isSafe = data['is_safe'] ?? false;
        double confidence = (data['confidence'] ?? 0.0).toDouble();
        String label = data['label'] ?? 'unknown';

        print("🤖 AI Result: ${data['status']} ($confidence% confidence)");

        return {
          'is_safe': isSafe,
          'confidence': confidence,
          'label': label,
          'status': data['status'],
          'scan_time_ms': data['scan_time_ms'],
        };
      } else {
        print("❌ AI Server Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ AI Connection Error: $e");
      return null;
    }
  }
}
