import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/volunteer.dart';

class UserService {
  final FirebaseFirestore _firestore;

  UserService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users');

  /// Retrieves a user document by `uid`.
  Future<Volunteer?> getUser(String uid) async {
    try {
      final doc = await _collection.doc(uid).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return Volunteer.fromMap(doc.data()!, docId: doc.id);
    } catch (e) {
      rethrow;
    }
  }

  /// Creates a new user profile document in `users/{user.uid}`.
  Future<void> createUserProfile(Volunteer user) async {
    try {
      final data = user.toMap();
      await _collection.doc(user.uid).set(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Updates specific fields of a user document by `uid`.
  Future<void> updateUser(
    String uid,
    Map<String, dynamic> updates,
  ) async {
    try {
      final Map<String, dynamic> finalUpdates = Map.from(updates);
      if (!finalUpdates.containsKey('updatedAt')) {
        finalUpdates['updatedAt'] = FieldValue.serverTimestamp();
      }
      await _collection.doc(uid).update(finalUpdates);
    } catch (e) {
      rethrow;
    }
  }

  /// Updates only the user's status and refreshes `updatedAt`.
  Future<void> updateStatus(
    String uid,
    VolunteerStatus status,
  ) async {
    try {
      await _collection.doc(uid).update({
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Watches real-time updates for a specific user document by `uid`.
  Stream<Volunteer?> watchUser(String uid) {
    try {
      return _collection.doc(uid).snapshots().map((doc) {
        if (!doc.exists || doc.data() == null) {
          return null;
        }
        return Volunteer.fromMap(doc.data()!, docId: doc.id);
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Watches real-time updates for all users whose role is "volunteer".
  Stream<List<Volunteer>> watchVolunteers() {
    try {
      return _collection
          .where('role', isEqualTo: 'volunteer')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return Volunteer.fromMap(doc.data(), docId: doc.id);
        }).toList();
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Watches real-time updates for all users in the `users` collection.
  Stream<List<Volunteer>> watchUsers() {
    try {
      return _collection.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return Volunteer.fromMap(doc.data(), docId: doc.id);
        }).toList();
      });
    } catch (e) {
      rethrow;
    }
  }
}
