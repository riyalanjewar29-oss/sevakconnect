import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/emergency_report.dart';

class EmergencyService {
  final FirebaseFirestore _firestore;

  EmergencyService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('emergencies');

  /// Creates a new emergency report in the `emergencies` collection.
  Future<String> createEmergency(EmergencyReport report) async {
    try {
      final docRef = _collection.doc();
      final data = report.copyWith(id: docRef.id).toMap();
      await docRef.set(data);
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Retrieves an emergency report by ID.
  Future<EmergencyReport?> getEmergency(String emergencyId) async {
    try {
      final doc = await _collection.doc(emergencyId).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return EmergencyReport.fromMap(doc.data()!, docId: doc.id);
    } catch (e) {
      rethrow;
    }
  }

  /// Updates arbitrary fields of an emergency report by ID.
  Future<void> updateEmergency(
    String emergencyId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final Map<String, dynamic> finalUpdates = Map.from(updates);
      if (!finalUpdates.containsKey('updatedAt')) {
        finalUpdates['updatedAt'] = FieldValue.serverTimestamp();
      }
      await _collection.doc(emergencyId).update(finalUpdates);
    } catch (e) {
      rethrow;
    }
  }

  /// Updates the status of an emergency report and refreshes timestamps.
  Future<void> updateStatus(
    String emergencyId,
    EmergencyStatus status,
  ) async {
    try {
      final Map<String, dynamic> updates = {
        'status': status.firestoreValue,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (status == EmergencyStatus.resolved) {
        updates['resolvedAt'] = FieldValue.serverTimestamp();
      }
      await _collection.doc(emergencyId).update(updates);
    } catch (e) {
      rethrow;
    }
  }

  /// Resolves an emergency report by updating status to resolved and setting resolvedAt.
  Future<void> resolveEmergency(String emergencyId) async {
    try {
      await _collection.doc(emergencyId).update({
        'status': EmergencyStatus.resolved.firestoreValue,
        'resolvedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Deletes an emergency report explicitly by ID.
  Future<void> deleteEmergency(String emergencyId) async {
    try {
      await _collection.doc(emergencyId).delete();
    } catch (e) {
      rethrow;
    }
  }

  /// Watches real-time updates for all emergencies ordered by `createdAt` descending.
  Stream<List<EmergencyReport>> watchEmergencies() {
    try {
      return _collection
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return EmergencyReport.fromMap(doc.data(), docId: doc.id);
        }).toList();
      });
    } catch (e) {
      rethrow;
    }
  }
}
