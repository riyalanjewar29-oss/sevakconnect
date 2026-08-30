import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/emergency_report.dart';
import '../models/crowd_condition.dart';
import '../models/volunteer.dart';
import '../models/overview_metrics.dart';

/// Service and state management container for the Admin & Police Dashboard.
///
/// Connected to Cloud Firestore Collections:
/// 1. `users` -> Volunteer roster and field status
/// 2. `emergencies` -> Live priority incident reports
/// 3. `crowd_reports` -> Real-time crowd density sectors
class AdminDashboardService extends ChangeNotifier {
  // Core Operational State (strictly reactive, defaults to empty list)
  List<EmergencyReport> _emergencies = [];
  List<CrowdCondition> _crowdConditions = [];
  List<Volunteer> _volunteers = [];

  final bool _isLoading = false;
  String? _errorMessage;

  // Active Role context: "Admin" or "Police"
  String _activeRole = 'Admin';

  // Firestore stream subscriptions
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _usersSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _emergenciesSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _crowdReportsSubscription;

  AdminDashboardService() {
    initFirestoreStreams();
  }

  // Getters
  List<EmergencyReport> get emergencies => List.unmodifiable(_emergencies);
  List<CrowdCondition> get crowdConditions => List.unmodifiable(_crowdConditions);
  List<Volunteer> get volunteers => List.unmodifiable(_volunteers);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get activeRole => _activeRole;

  void toggleRole() {
    _activeRole = _activeRole == 'Admin' ? 'Police' : 'Admin';
    notifyListeners();
  }

  void setRole(String role) {
    if (_activeRole != role) {
      _activeRole = role;
      notifyListeners();
    }
  }

  // Calculated Overview Metrics
  OverviewMetrics get metrics {
    final activeEmergenciesList = _emergencies
        .where((e) => e.status != EmergencyStatus.resolved)
        .toList();

    final criticalZonesCount = _crowdConditions
        .where((c) => c.crowdLevel == CrowdLevel.critical)
        .map((c) => c.zoneId)
        .toSet()
        .length;

    final activeVolunteersCount = _volunteers
        .where((v) => v.status == VolunteerStatus.active)
        .length;

    final unresolvedCount = _emergencies
        .where((e) => e.status != EmergencyStatus.resolved)
        .length;

    return OverviewMetrics(
      activeEmergencies: activeEmergenciesList.length,
      criticalZones: criticalZonesCount,
      activeVolunteers: activeVolunteersCount,
      unresolvedIncidents: unresolvedCount,
    );
  }

  /// Initializes real-time Cloud Firestore snapshot listeners.
  /// Gracefully catches errors when offline or when collections are newly created.
  void initFirestoreStreams() {
    try {
      if (Firebase.apps.isEmpty) {
        return;
      }

      final firestore = FirebaseFirestore.instance;

      // 1. Listen to `users` collection
      _usersSubscription?.cancel();
      _usersSubscription = firestore.collection('users').snapshots().listen(
        (snapshot) {
          _volunteers = snapshot.docs.map((doc) {
            final data = doc.data();
            return Volunteer.fromMap(data, docId: doc.id);
          }).toList();
          notifyListeners();
        },
        onError: (err) {
          debugPrint('Firestore users stream notice: $err');
        },
      );

      // 2. Listen to `emergencies` collection
      _emergenciesSubscription?.cancel();
      _emergenciesSubscription = firestore.collection('emergencies').snapshots().listen(
        (snapshot) {
          _emergencies = snapshot.docs.map((doc) {
            final data = doc.data();
            return EmergencyReport.fromMap(data, docId: doc.id);
          }).toList();
          notifyListeners();
        },
        onError: (err) {
          debugPrint('Firestore emergencies stream notice: $err');
        },
      );

      // 3. Listen to `crowd_reports` collection
      _crowdReportsSubscription?.cancel();
      _crowdReportsSubscription = firestore.collection('crowd_reports').snapshots().listen(
        (snapshot) {
          _crowdConditions = snapshot.docs.map((doc) {
            final data = doc.data();
            return CrowdCondition.fromMap(data, docId: doc.id);
          }).toList();
          notifyListeners();
        },
        onError: (err) {
          debugPrint('Firestore crowd_reports stream notice: $err');
        },
      );
    } catch (e) {
      debugPrint('Firestore stream init notice: $e');
    }
  }

  /// Update the status of an emergency report in local state and Firestore.
  Future<void> updateEmergencyStatus(String emergencyId, EmergencyStatus newStatus) async {
    final idx = _emergencies.indexWhere((e) => e.id == emergencyId);
    if (idx != -1) {
      _emergencies[idx] = _emergencies[idx].copyWith(status: newStatus);
      notifyListeners();
    }

    try {
      if (Firebase.apps.isNotEmpty) {
        final Map<String, dynamic> updateData = {
          'status': newStatus.firestoreValue,
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (newStatus == EmergencyStatus.resolved) {
          updateData['resolvedAt'] = FieldValue.serverTimestamp();
        }
        await FirebaseFirestore.instance.collection('emergencies').doc(emergencyId).update(updateData);
      }
    } catch (e) {
      debugPrint('Firestore updateEmergencyStatus notice: $e');
    }
  }

  // Filter Methods
  List<EmergencyReport> filterEmergencies({
    String query = '',
    EmergencySeverity? severity,
    EmergencyStatus? status,
  }) {
    return _emergencies.where((e) {
      final matchesQuery = query.isEmpty ||
          e.type.toLowerCase().contains(query.toLowerCase()) ||
          e.location.toLowerCase().contains(query.toLowerCase()) ||
          e.reportedBy.toLowerCase().contains(query.toLowerCase());

      final matchesSeverity = severity == null || e.severity == severity;
      final matchesStatus = status == null || e.status == status;

      return matchesQuery && matchesSeverity && matchesStatus;
    }).toList();
  }

  List<CrowdCondition> filterCrowdConditions({
    String query = '',
    CrowdLevel? crowdLevel,
  }) {
    return _crowdConditions.where((c) {
      final matchesQuery = query.isEmpty ||
          c.zoneId.toLowerCase().contains(query.toLowerCase()) ||
          c.description.toLowerCase().contains(query.toLowerCase());

      final matchesLevel = crowdLevel == null || c.crowdLevel == crowdLevel;

      return matchesQuery && matchesLevel;
    }).toList();
  }

  List<Volunteer> filterVolunteers({
    String query = '',
    String team = 'All',
    VolunteerStatus? status,
  }) {
    return _volunteers.where((v) {
      final matchesQuery = query.isEmpty ||
          v.name.toLowerCase().contains(query.toLowerCase()) ||
          v.role.toLowerCase().contains(query.toLowerCase()) ||
          v.currentLocation.toLowerCase().contains(query.toLowerCase()) ||
          v.phone.contains(query);

      final matchesTeam = team == 'All' || v.team.toLowerCase() == team.toLowerCase();
      final matchesStatus = status == null || v.status == status;

      return matchesQuery && matchesTeam && matchesStatus;
    }).toList();
  }

  @override
  void dispose() {
    _usersSubscription?.cancel();
    _emergenciesSubscription?.cancel();
    _crowdReportsSubscription?.cancel();
    super.dispose();
  }
}
