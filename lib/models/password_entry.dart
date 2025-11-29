class PasswordEntry {
  final String id;
  final String url;
  final String domain;
  final String username;
  final String password;
  final DateTime timestamp;
  final DateTime? lastUsed;

  PasswordEntry({
    required this.id,
    required this.url,
    required this.domain,
    required this.username,
    required this.password,
    required this.timestamp,
    this.lastUsed,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'domain': domain,
      'username': username,
      'password': password,
      'timestamp': timestamp.toIso8601String(),
      'lastUsed': lastUsed?.toIso8601String(),
    };
  }

  factory PasswordEntry.fromJson(Map<String, dynamic> json) {
    return PasswordEntry(
      id: json['id'] as String,
      url: json['url'] as String,
      domain: json['domain'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      lastUsed: json['lastUsed'] != null 
          ? DateTime.parse(json['lastUsed'] as String) 
          : null,
    );
  }

  PasswordEntry copyWith({
    String? id,
    String? url,
    String? domain,
    String? username,
    String? password,
    DateTime? timestamp,
    DateTime? lastUsed,
  }) {
    return PasswordEntry(
      id: id ?? this.id,
      url: url ?? this.url,
      domain: domain ?? this.domain,
      username: username ?? this.username,
      password: password ?? this.password,
      timestamp: timestamp ?? this.timestamp,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }
}
