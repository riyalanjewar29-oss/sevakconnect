class AppAlert {
  final String id;
  final String title;
  final String description;
  final String type; // crowd, river_safety, emergency, route, supply, general
  final String severity; // CRITICAL, HIGH, WARNING, INFO
  final String location;
  final DateTime createdAt;
  final bool isRead;

  const AppAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.severity,
    this.location = '',
    required this.createdAt,
    this.isRead = false,
  });

  bool get isCritical => severity.toUpperCase() == 'CRITICAL';
  bool get isHigh => severity.toUpperCase() == 'HIGH';
  bool get isWarning => severity.toUpperCase() == 'WARNING';
  bool get isInfo => severity.toUpperCase() == 'INFO';

  AppAlert copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    String? severity,
    String? location,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return AppAlert(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  factory AppAlert.fromJson(Map<String, dynamic> json) {
    return AppAlert(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: json['type'] as String? ?? 'general',
      severity: (json['severity'] as String? ?? 'INFO').toUpperCase(),
      location: json['location'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      isRead: json['is_read'] == true || json['is_read'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'severity': severity,
      'location': location,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
    };
  }
}
