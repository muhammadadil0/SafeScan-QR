import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:math' as math;

class MLService {
  Interpreter? _interpreter;
  bool _isModelLoaded = false;

  // Class labels
  final List<String> _classLabels = ['Safe', 'Phishing', 'Malware', 'Spam'];

  /// Initialize the ML model
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/url_classifier.tflite');
      _isModelLoaded = true;
      print('✅ ML Model loaded successfully');
    } catch (e) {
      print('❌ Error loading ML model: $e');
      _isModelLoaded = false;
    }
  }

  /// Check if model is loaded
  bool get isModelLoaded => _isModelLoaded;

  /// Extract features from URL (must match Python training script)
  List<double> _extractFeatures(String url) {
    List<double> features = [];

    try {
      final uri = Uri.parse(url);
      final domain = uri.host;
      final path = uri.path;
      final query = uri.query;

      // 1. URL Length
      features.add(url.length.toDouble());

      // 2. Domain Length
      features.add(domain.length.toDouble());

      // 3. Path Length
      features.add(path.length.toDouble());

      // 4. Number of dots
      features.add(_countChar(url, '.').toDouble());

      // 5. Number of hyphens
      features.add(_countChar(url, '-').toDouble());

      // 6. Number of underscores
      features.add(_countChar(url, '_').toDouble());

      // 7. Number of slashes
      features.add(_countChar(url, '/').toDouble());

      // 8. Number of question marks
      features.add(_countChar(url, '?').toDouble());

      // 9. Number of equals
      features.add(_countChar(url, '=').toDouble());

      // 10. Number of @ symbols
      features.add(_countChar(url, '@').toDouble());

      // 11. Number of ampersands
      features.add(_countChar(url, '&').toDouble());

      // 12. Number of digits
      features.add(_countDigits(url).toDouble());

      // 13. Has HTTPS
      features.add(uri.scheme == 'https' ? 1.0 : 0.0);

      // 14. Has IP address
      features.add(_isIPAddress(domain) ? 1.0 : 0.0);

      // 15. Number of subdomains
      final subdomains = domain.split('.').length - 2;
      features.add(subdomains > 0 ? subdomains.toDouble() : 0.0);

      // 16. Domain has numbers
      features.add(_hasDigits(domain) ? 1.0 : 0.0);

      // 17. Suspicious keywords count
      features.add(_countSuspiciousKeywords(url).toDouble());

      // 18. Has port number
      features.add(uri.hasPort ? 1.0 : 0.0);

      // 19. TLD length
      final tld = domain.split('.').last;
      features.add(tld.length.toDouble());

      // 20. Has suspicious TLD
      features.add(_hasSuspiciousTLD(domain) ? 1.0 : 0.0);

      // 21. Character entropy
      features.add(_calculateEntropy(domain));

      // 22. Ratio of digits to letters
      final letters = _countLetters(url);
      final digits = _countDigits(url);
      features.add(digits / (letters + 1));

      // 23. Has double slashes in path
      features.add(path.contains('//') ? 1.0 : 0.0);

      // 24. Number of parameters
      final params = query.isNotEmpty ? query.split('&').length : 0;
      features.add(params.toDouble());

      // 25. Has fragment
      features.add(uri.hasFragment ? 1.0 : 0.0);

      // 26. Vowel to consonant ratio
      features.add(_vowelConsonantRatio(domain));

      // Model expects exactly 26 features
      // Ensure we have exactly 26 features
      if (features.length > 26) {
        features = features.sublist(0, 26);
      } else {
        while (features.length < 26) {
          features.add(0.0);
        }
      }
    } catch (e) {
      // If parsing fails, return zeros
      features = List.filled(26, 0.0);
    }

    return features;
  }

  /// Predict URL classification using ML model
  Future<MLPrediction?> predictURL(String url) async {
    if (!_isModelLoaded || _interpreter == null) {
      print('⚠️ ML Model not loaded');
      return null;
    }

    try {
      // Extract features
      final features = _extractFeatures(url);

      // Prepare input tensor [1, 30]
      final input = [features];

      // Prepare output tensor [1, 4]
      final output = List.filled(1, List.filled(4, 0.0)).map((e) => List<double>.from(e)).toList();

      // Run inference
      _interpreter!.run(input, output);

      // Get predictions
      final probabilities = output[0];
      final maxIndex = probabilities.indexOf(probabilities.reduce(math.max));
      final confidence = probabilities[maxIndex];

      return MLPrediction(
        className: _classLabels[maxIndex],
        classIndex: maxIndex,
        confidence: confidence,
        probabilities: probabilities,
      );
    } catch (e) {
      print('❌ Error during prediction: $e');
      return null;
    }
  }

  // Helper methods
  int _countChar(String str, String char) {
    return char.allMatches(str).length;
  }

  int _countDigits(String str) {
    return str.split('').where((c) => RegExp(r'\d').hasMatch(c)).length;
  }

  int _countLetters(String str) {
    return str.split('').where((c) => RegExp(r'[a-zA-Z]').hasMatch(c)).length;
  }

  bool _hasDigits(String str) {
    return RegExp(r'\d').hasMatch(str);
  }

  bool _isIPAddress(String host) {
    final parts = host.split('.');
    if (parts.length != 4) return false;
    for (final part in parts) {
      final num = int.tryParse(part);
      if (num == null || num < 0 || num > 255) return false;
    }
    return true;
  }

  int _countSuspiciousKeywords(String url) {
    final keywords = [
      'login', 'verify', 'account', 'update', 'secure', 'banking',
      'paypal', 'amazon', 'microsoft', 'apple', 'google', 'facebook',
      'password', 'confirm', 'suspended', 'locked', 'urgent', 'click'
    ];
    return keywords.where((kw) => url.toLowerCase().contains(kw)).length;
  }

  bool _hasSuspiciousTLD(String domain) {
    final suspiciousTLDs = ['.tk', '.ml', '.ga', '.cf', '.gq', '.xyz', '.top'];
    return suspiciousTLDs.any((tld) => domain.endsWith(tld));
  }

  double _calculateEntropy(String str) {
    if (str.isEmpty) return 0.0;

    final charFreq = <String, int>{};
    for (final char in str.split('')) {
      charFreq[char] = (charFreq[char] ?? 0) + 1;
    }

    double entropy = 0.0;
    for (final freq in charFreq.values) {
      final p = freq / str.length;
      entropy -= p * (math.log(p) / math.ln2);
    }

    return entropy;
  }

  double _vowelConsonantRatio(String str) {
    final vowels = str.toLowerCase().split('').where((c) => 'aeiou'.contains(c)).length;
    final consonants = str.toLowerCase().split('').where((c) => RegExp(r'[a-z]').hasMatch(c) && !'aeiou'.contains(c)).length;
    return vowels / (consonants + 1);
  }

  /// Dispose the interpreter
  void dispose() {
    _interpreter?.close();
    _isModelLoaded = false;
  }
}

/// ML Prediction result
class MLPrediction {
  final String className;
  final int classIndex;
  final double confidence;
  final List<double> probabilities;

  MLPrediction({
    required this.className,
    required this.classIndex,
    required this.confidence,
    required this.probabilities,
  });

  bool get isSafe => classIndex == 0;
  bool get isPhishing => classIndex == 1;
  bool get isMalware => classIndex == 2;
  bool get isSpam => classIndex == 3;

  @override
  String toString() {
    return 'MLPrediction(class: $className, confidence: ${(confidence * 100).toStringAsFixed(2)}%)';
  }
}
