import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lost_found_case.dart';

class LostFoundService {
  final FirebaseFirestore _firestore;

  LostFoundService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('lost_found_cases');

  /// Creates a new lost & found case document with a Firestore-generated ID.
  Future<String> createCase(LostFoundCase caseData) async {
    try {
      final docRef = _collection.doc();
      final data = caseData.copyWith(id: docRef.id).toMap();
      await docRef.set(data);
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Retrieves a single case by ID.
  Future<LostFoundCase?> getCase(String caseId) async {
    try {
      final doc = await _collection.doc(caseId).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return LostFoundCase.fromMap(doc.data()!, docId: doc.id);
    } catch (e) {
      rethrow;
    }
  }

  /// Updates specific fields of a case by ID.
  Future<void> updateCase(
    String caseId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final Map<String, dynamic> finalUpdates = Map.from(updates);
      if (!finalUpdates.containsKey('updatedAt')) {
        finalUpdates['updatedAt'] = FieldValue.serverTimestamp();
      }
      await _collection.doc(caseId).update(finalUpdates);
    } catch (e) {
      rethrow;
    }
  }

  /// Updates the status of a case and refreshes the `updatedAt` timestamp.
  Future<void> updateStatus(
    String caseId,
    LostFoundStatus status,
  ) async {
    try {
      await _collection.doc(caseId).update({
        'status': status.firestoreValue,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Deletes a case document explicitly.
  Future<void> deleteCase(String caseId) async {
    try {
      await _collection.doc(caseId).delete();
    } catch (e) {
      rethrow;
    }
  }

  /// Watches real-time updates for all lost & found cases ordered by `createdAt` descending.
  Stream<List<LostFoundCase>> watchCases() {
    try {
      return _collection
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return LostFoundCase.fromMap(doc.data(), docId: doc.id);
        }).toList();
      });
    } catch (e) {
      rethrow;
    }
  }
}
