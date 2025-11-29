class BrowserHistoryItem {
  final String id;
  final String url;
  final String title;
  final DateTime timestamp;
  final int visitCount;
  final Duration timeSpent;

  BrowserHistoryItem({
    required this.id,
    required this.url,
    required this.title,
    required this.timestamp,
    this.visitCount = 1,
    this.timeSpent = Duration.zero,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'timestamp': timestamp.toIso8601String(),
      'visitCount': visitCount,
      'timeSpent': timeSpent.inSeconds,
    };
  }

  factory BrowserHistoryItem.fromJson(Map<String, dynamic> json) {
    return BrowserHistoryItem(
      id: json['id'] as String,
      url: json['url'] as String,
      title: json['title'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      visitCount: json['visitCount'] as int? ?? 1,
      timeSpent: Duration(seconds: json['timeSpent'] as int? ?? 0),
    );
  }

  BrowserHistoryItem copyWith({
    String? id,
    String? url,
    String? title,
    DateTime? timestamp,
    int? visitCount,
    Duration? timeSpent,
  }) {
    return BrowserHistoryItem(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      timestamp: timestamp ?? this.timestamp,
      visitCount: visitCount ?? this.visitCount,
      timeSpent: timeSpent ?? this.timeSpent,
    );
  }
}
