import 'emergency_report.dart';

class OverviewMetrics {
  final int activeEmergencies;
  final int criticalZones;
  final int activeVolunteers;
  final int unresolvedIncidents;
  final List<EmergencyReport> recentEmergencies;

  const OverviewMetrics({
    this.activeEmergencies = 0,
    this.criticalZones = 0,
    this.activeVolunteers = 0,
    this.unresolvedIncidents = 0,
    this.recentEmergencies = const [],
  });

  OverviewMetrics copyWith({
    int? activeEmergencies,
    int? criticalZones,
    int? activeVolunteers,
    int? unresolvedIncidents,
    List<EmergencyReport>? recentEmergencies,
  }) {
    return OverviewMetrics(
      activeEmergencies: activeEmergencies ?? this.activeEmergencies,
      criticalZones: criticalZones ?? this.criticalZones,
      activeVolunteers: activeVolunteers ?? this.activeVolunteers,
      unresolvedIncidents: unresolvedIncidents ?? this.unresolvedIncidents,
      recentEmergencies: recentEmergencies ?? this.recentEmergencies,
    );
  }
}
