import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

enum TaskPriority {
  low,
  medium,
  high,
  critical,
}

extension TaskPriorityExtension on TaskPriority {
  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return 'LOW';
      case TaskPriority.medium:
        return 'MEDIUM';
      case TaskPriority.high:
        return 'HIGH';
      case TaskPriority.critical:
        return 'CRITICAL';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.low:
        return const Color(0xFF2E7D32);
      case TaskPriority.medium:
        return const Color(0xFFE65100);
      case TaskPriority.high:
        return const Color(0xFFC62828);
      case TaskPriority.critical:
        return const Color(0xFFB71C1C);
    }
  }

  Color get containerColor {
    switch (this) {
      case TaskPriority.low:
        return const Color(0xFFE8F5E9);
      case TaskPriority.medium:
        return const Color(0xFFFFF3E0);
      case TaskPriority.high:
        return const Color(0xFFFFEBEE);
      case TaskPriority.critical:
        return const Color(0xFFFFCDD2);
    }
  }

  static TaskPriority fromString(String value) {
    switch (value.toLowerCase().trim()) {
      case 'low':
        return TaskPriority.low;
      case 'high':
        return TaskPriority.high;
      case 'critical':
        return TaskPriority.critical;
      case 'medium':
      default:
        return TaskPriority.medium;
    }
  }
}

enum TaskStatus {
  pending,
  inProgress,
  completed,
}

extension TaskStatusExtension on TaskStatus {
  String get displayName {
    switch (this) {
      case TaskStatus.pending:
        return 'PENDING';
      case TaskStatus.inProgress:
        return 'IN PROGRESS';
      case TaskStatus.completed:
        return 'COMPLETED';
    }
  }

  Color get color {
    switch (this) {
      case TaskStatus.pending:
        return const Color(0xFF5D4037);
      case TaskStatus.inProgress:
        return const Color(0xFFE65100);
      case TaskStatus.completed:
        return const Color(0xFF2E7D32);
    }
  }

  Color get containerColor {
    switch (this) {
      case TaskStatus.pending:
        return const Color(0xFFEFEBE9);
      case TaskStatus.inProgress:
        return const Color(0xFFFFF3E0);
      case TaskStatus.completed:
        return const Color(0xFFE8F5E9);
    }
  }

  static TaskStatus fromString(String value) {
    switch (value.toUpperCase().trim()) {
      case 'IN PROGRESS':
      case 'INPROGRESS':
      case 'IN_PROGRESS':
        return TaskStatus.inProgress;
      case 'COMPLETED':
      case 'RESOLVED':
      case 'DONE':
        return TaskStatus.completed;
      case 'PENDING':
      default:
        return TaskStatus.pending;
    }
  }
}

class AppTask {
  final String id;
  final String title;
  final String description;
  final TaskPriority priority;
  final TaskStatus status;
  final String assignedTo;
  final String locationName;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppTask({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.assignedTo,
    required this.locationName,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  LatLng? get position {
    if (latitude == null || longitude == null) return null;
    return LatLng(latitude!, longitude!);
  }

  AppTask copyWith({
    String? id,
    String? title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    String? assignedTo,
    String? locationName,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory AppTask.fromJson(Map<String, dynamic> json) {
    return AppTask(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled Task',
      description: json['description'] as String? ?? '',
      priority: TaskPriorityExtension.fromString(json['priority'] as String? ?? 'MEDIUM'),
      status: TaskStatusExtension.fromString(json['status'] as String? ?? 'PENDING'),
      assignedTo: json['assigned_to'] as String? ?? 'volunteer_demo',
      locationName: json['location_name'] as String? ?? 'Wari Corridor',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
