import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/crowd_condition.dart';

class CrowdReportService {
  final FirebaseFirestore _firestore;

  CrowdReportService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('crowd_reports');

  /// Creates a new crowd report document in `crowd_reports`.
  /// Does NOT run during initialization.
  Future<String> createCrowdReport(CrowdCondition report) async {
    try {
      final docRef = _collection.doc();
      final data = CrowdCondition(
        id: docRef.id,
        zoneId: report.zoneId,
        crowdLevel: report.crowdLevel,
        latitude: report.latitude,
        longitude: report.longitude,
        reportedBy: report.reportedBy,
        description: report.description,
        createdAt: report.createdAt,
      ).toMap();
      await docRef.set(data);
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Retrieves a single crowd report by ID.
  Future<CrowdCondition?> getCrowdReport(String reportId) async {
    try {
      final doc = await _collection.doc(reportId).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return CrowdCondition.fromMap(doc.data()!, docId: doc.id);
    } catch (e) {
      rethrow;
    }
  }

  /// Updates specific fields of a crowd report by ID.
  Future<void> updateCrowdReport(
    String reportId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _collection.doc(reportId).update(updates);
    } catch (e) {
      rethrow;
    }
  }

  /// Deletes a crowd report explicitly by ID.
  Future<void> deleteCrowdReport(String reportId) async {
    try {
      await _collection.doc(reportId).delete();
    } catch (e) {
      rethrow;
    }
  }

  /// Watches real-time updates for all crowd reports ordered by `createdAt` descending.
  Stream<List<CrowdCondition>> watchCrowdReports() {
    try {
      return _collection
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return CrowdCondition.fromMap(doc.data(), docId: doc.id);
        }).toList();
      });
    } catch (e) {
      rethrow;
    }
  }
}
