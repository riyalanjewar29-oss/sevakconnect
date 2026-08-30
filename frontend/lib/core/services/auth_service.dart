import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Gets the currently authenticated user, or null if not logged in.
  User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Signs in a user with email and password.
  Future<User?> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Authenticates with email and password, verifies the Firestore `users/{uid}` profile,
  /// validates that the role is one of 'admin', 'police', 'volunteer', and returns the validated role string.
  Future<String> loginAndGetRole(String email, String password) async {
    final user = await signInWithEmailPassword(email, password);
    if (user == null) {
      debugPrint(
          '[AUTH DIAGNOSTIC] signInWithEmailPassword returned null user');
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Authentication failed. User not found.',
      );
    }

    final String uid = user.uid;
    debugPrint(
        '[AUTH DIAGNOSTIC] 1. Firebase.app().options.projectId: "${Firebase.app().options.projectId}"');
    debugPrint(
        '[AUTH DIAGNOSTIC] 2. Firebase.app().options.appId: "${Firebase.app().options.appId}"');
    debugPrint(
        '[AUTH DIAGNOSTIC] 3. FirebaseAuth.instance.currentUser?.uid: "${FirebaseAuth.instance.currentUser?.uid}"');
    debugPrint(
        '[AUTH DIAGNOSTIC] 4. FirebaseFirestore.instance.app.options.projectId: "${FirebaseFirestore.instance.app.options.projectId}"');
    debugPrint('[AUTH DIAGNOSTIC] 5. Exact Firestore Path: "users/$uid"');

    final doc = await _firestore.collection('users').doc(uid).get();
    debugPrint('[AUTH DIAGNOSTIC] Firestore doc.exists: ${doc.exists}');
    debugPrint('[AUTH DIAGNOSTIC] Firestore doc.data(): ${doc.data()}');

    if (!doc.exists || doc.data() == null) {
      debugPrint(
          '[AUTH DIAGNOSTIC] Document at "users/$uid" DOES NOT EXIST or data is null.');
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'profile-not-found',
        message:
            'No user profile found in database for this account. Access denied.',
      );
    }

    final rawRole = doc.data()?['role'] as String?;
    debugPrint('[AUTH DIAGNOSTIC] Extracted rawRole: "$rawRole"');
    if (rawRole == null || rawRole.trim().isEmpty) {
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'invalid-role',
        message:
            'User account has no operational role assigned. Access denied.',
      );
    }

    final cleanRole = rawRole.toLowerCase().trim();
    if (cleanRole != 'admin' &&
        cleanRole != 'police' &&
        cleanRole != 'volunteer') {
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'unauthorized-role',
        message:
            'Invalid role "$cleanRole". Only admin, police, or volunteer accounts are authorized.',
      );
    }

    return cleanRole;
  }

  /// Registers a new user account with email and password.
  Future<User?> registerWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Retrieves the role string ('admin', 'police', 'volunteer') from Firestore `users/{uid}`.
  Future<String?> getCurrentUserRole() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return null;
      }

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return doc.data()?['role'] as String?;
    } catch (e) {
      rethrow;
    }
  }

  /// Returns true if current user has 'admin' role.
  Future<bool> isAdmin() async {
    final role = await getCurrentUserRole();
    return role?.toLowerCase() == 'admin';
  }

  /// Returns true if current user has 'police' role.
  Future<bool> isPolice() async {
    final role = await getCurrentUserRole();
    return role?.toLowerCase() == 'police';
  }

  /// Returns true if current user has 'volunteer' role.
  Future<bool> isVolunteer() async {
    final role = await getCurrentUserRole();
    return role?.toLowerCase() == 'volunteer';
  }
}
