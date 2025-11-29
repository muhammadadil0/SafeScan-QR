class FormDataItem {
  final String id;
  final String url;
  final String domain;
  final Map<String, String> fields;
  final DateTime timestamp;
  final bool hasPassword;

  FormDataItem({
    required this.id,
    required this.url,
    required this.domain,
    required this.fields,
    required this.timestamp,
    this.hasPassword = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'domain': domain,
      'fields': fields,
      'timestamp': timestamp.toIso8601String(),
      'hasPassword': hasPassword,
    };
  }

  factory FormDataItem.fromJson(Map<String, dynamic> json) {
    return FormDataItem(
      id: json['id'] as String,
      url: json['url'] as String,
      domain: json['domain'] as String,
      fields: Map<String, String>.from(json['fields'] as Map),
      timestamp: DateTime.parse(json['timestamp'] as String),
      hasPassword: json['hasPassword'] as bool? ?? false,
    );
  }
}
