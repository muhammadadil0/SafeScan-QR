import 'package:flutter_test/flutter_test.dart';
import 'package:safe_scan_qr/services/security_service.dart';
import 'package:safe_scan_qr/models/scan_result.dart';

void main() {
  group('SecurityService Tests', () {
    final service = SecurityService();

    test('Safe URL should return safe status', () async {
      final result = await service.analyzeUrl('https://google.com');
      expect(result.status, SecurityStatus.safe);
    });

    test('HTTP URL should be suspicious', () async {
      final result = await service.analyzeUrl('http://example.com');
      expect(result.status, SecurityStatus.suspicious);
      expect(result.riskFactors.any((r) => r.contains('HTTPS')), true);
    });

    test('Phishing keyword should be suspicious', () async {
      final result = await service.analyzeUrl('https://example-login.com');
      expect(result.status, SecurityStatus.suspicious);
      expect(result.riskFactors.any((r) => r.contains('login')), true);
    });

    test('Typosquatting should be dangerous', () async {
      final result = await service.analyzeUrl('https://faceb00k.com');
      expect(result.status, SecurityStatus.dangerous);
      expect(result.riskFactors.any((r) => r.contains('typosquatting')), true);
    });

    test('Suspicious domain (free hosting) should be suspicious', () async {
      final result = await service.analyzeUrl('https://mysite.000webhost.com');
      expect(result.status, SecurityStatus.suspicious);
      expect(result.riskFactors.any((r) => r.contains('000webhost')), true);
    });

    test('Multiple risks should escalate to dangerous', () async {
      // HTTP + Phishing Keyword + Suspicious Domain
      final result = await service.analyzeUrl('http://login.000webhost.com');
      expect(result.status, SecurityStatus.dangerous);
    });
  });
}
