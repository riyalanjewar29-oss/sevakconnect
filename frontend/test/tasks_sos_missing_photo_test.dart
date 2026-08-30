import 'package:flutter_test/flutter_test.dart';
import 'package:sevak_connect/core/models/app_task.dart';
import 'package:sevak_connect/core/models/lost_found_case.dart';
import 'package:sevak_connect/core/config/api_config.dart';

void main() {
  group('AppTask Model & Enums Unit Tests', () {
    test('TaskPriorityExtension parses and maps colors properly', () {
      expect(TaskPriorityExtension.fromString('LOW'), TaskPriority.low);
      expect(TaskPriorityExtension.fromString('MEDIUM'), TaskPriority.medium);
      expect(TaskPriorityExtension.fromString('HIGH'), TaskPriority.high);
      expect(TaskPriorityExtension.fromString('CRITICAL'), TaskPriority.critical);
      expect(TaskPriority.high.displayName, 'HIGH');
    });

    test('TaskStatusExtension parses and maps names properly', () {
      expect(TaskStatusExtension.fromString('PENDING'), TaskStatus.pending);
      expect(TaskStatusExtension.fromString('IN PROGRESS'), TaskStatus.inProgress);
      expect(TaskStatusExtension.fromString('COMPLETED'), TaskStatus.completed);
      expect(TaskStatus.inProgress.displayName, 'IN PROGRESS');
    });

    test('AppTask deserializes backend JSON accurately', () {
      final json = {
        'id': 'TSK-MED-001',
        'title': 'Check Medical Camp',
        'description': 'Verify first aid kits at Tent 2',
        'priority': 'HIGH',
        'status': 'PENDING',
        'assigned_to': 'volunteer_demo',
        'location_name': 'Wakhari Phata',
        'latitude': 17.6830,
        'longitude': 75.3190,
        'created_at': '2026-08-30T06:00:00Z',
        'updated_at': '2026-08-30T06:00:00Z',
      };

      final task = AppTask.fromJson(json);
      expect(task.id, 'TSK-MED-001');
      expect(task.title, 'Check Medical Camp');
      expect(task.priority, TaskPriority.high);
      expect(task.status, TaskStatus.pending);
      expect(task.position?.latitude, 17.6830);
      expect(task.position?.longitude, 75.3190);
    });
  });

  group('LostFoundCase Photo URL Tests', () {
    test('LostFoundCase handles optional photoUrl in fromMap and toMap', () {
      final map = {
        'id': 'MP-9901',
        'name': 'Ramesh Shinde',
        'age': 10,
        'gender': 'Male',
        'description': 'Green shirt, red bag',
        'latitude': 17.6750,
        'longitude': 75.3240,
        'is_minor': true,
        'reported_by': 'volunteer_demo',
        'status': 'open',
        'photo_url': 'image_ramesh.jpg',
        'created_at': '2026-08-30T06:00:00Z',
        'updated_at': '2026-08-30T06:00:00Z',
      };

      final mp = LostFoundCase.fromMap(map);
      expect(mp.id, 'MP-9901');
      expect(mp.isMinor, true);
      expect(mp.photoUrl, 'image_ramesh.jpg');

      final serialized = mp.toMap();
      expect(serialized['photoUrl'], 'image_ramesh.jpg');
    });

    test('LostFoundCase handles null photoUrl gracefully', () {
      final map = {
        'id': 'MP-9902',
        'name': null,
        'description': 'Senior pilgrim separated near temple',
        'latitude': 17.6750,
        'longitude': 75.3240,
        'is_minor': false,
        'status': 'open',
      };

      final mp = LostFoundCase.fromMap(map);
      expect(mp.photoUrl, isNull);
    });
  });

  group('ApiConfig Endpoints for Final MVP Features', () {
    test('Produces valid sos and tasks endpoints', () {
      expect(ApiConfig.sosEndpoint, contains('/sos'));
      expect(ApiConfig.tasksEndpoint, contains('/tasks'));
      expect(ApiConfig.taskStatusEndpoint('TSK-123'), contains('/tasks/TSK-123/status'));
    });
  });
}
