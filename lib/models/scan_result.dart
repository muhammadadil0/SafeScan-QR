enum SecurityStatus {
  safe,
  suspicious,
  dangerous,
}

class ScanResult {
  final String originalUrl;
  final SecurityStatus status;
  final List<String> riskFactors;
  final String finalUrl; // In case of redirects
  final int riskScore; // 0-100 scale
  final Map<String, dynamic> metadata; // Additional info (content type, etc.)
  final DateTime timestamp; // For history tracking

  ScanResult({
    required this.originalUrl,
    required this.status,
    required this.riskFactors,
    String? finalUrl,
    this.riskScore = 0,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
  })  : finalUrl = finalUrl ?? originalUrl,
        metadata = metadata ?? {},
        timestamp = timestamp ?? DateTime.now();

  bool get isSafe => status == SecurityStatus.safe;
  
  String get riskLevel {
    if (riskScore >= 70) return 'High Risk';
    if (riskScore >= 40) return 'Medium Risk';
    if (riskScore >= 20) return 'Low Risk';
    return 'Safe';
  }

  String get contentType => metadata['contentType'] ?? 'url';

  // Convert to JSON for storage
  Map<String, dynamic> toJson() => {
        'originalUrl': originalUrl,
        'status': status.toString(),
        'riskFactors': riskFactors,
        'finalUrl': finalUrl,
        'riskScore': riskScore,
        'metadata': metadata,
        'timestamp': timestamp.toIso8601String(),
      };

  // Create from JSON
  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      originalUrl: json['originalUrl'],
      status: SecurityStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => SecurityStatus.suspicious,
      ),
      riskFactors: List<String>.from(json['riskFactors']),
      finalUrl: json['finalUrl'],
      riskScore: json['riskScore'] ?? 0,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

