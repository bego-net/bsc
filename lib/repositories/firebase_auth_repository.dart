import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import '../utils/auth_utils.dart';
import 'auth_repository.dart';

/// Exception thrown when an authentication error occurs.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

/// Firebase implementation of [AuthRepository] using FirebaseAuth and Cloud Firestore.
class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<String?> get authStateChanges =>
      _auth.authStateChanges().map((user) => user?.uid);

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  Future<AppUser?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return AppUser.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<AppUser> signUp({
    required String name,
    required String username,
    required String password,
  }) async {
    final normalized = username.trim().toLowerCase();
    final hiddenEmail = usernameToEmail(normalized);
    try {
      // Firebase uniqueness is enforced via email uniqueness.
      final credential = await _auth.createUserWithEmailAndPassword(
        email: hiddenEmail,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException('Account creation failed. Please try again.');
      }

      await user.updateDisplayName(name.trim());

      final appUser = AppUser(
        uid: user.uid,
        name: name.trim(),
        email: hiddenEmail,
        username: normalized,
        role: 'member',
        createdAt: DateTime.now(),
        currentBook: 'John',
        currentChapter: 1,
        verseFrom: 1,
        verseTo: 1,
        reminderTime: '07:00',
        mustChangePassword: false,
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(appUser.toMap());

      return appUser;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e, isSignUp: true));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(e.toString());
    }
  }

  @override
  Future<AppUser> logIn({
    required String username,
    required String password,
  }) async {
    final normalized = username.trim().toLowerCase();
    final hiddenEmail = usernameToEmail(normalized);
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: hiddenEmail,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException('Sign in failed. Please check credentials.');
      }

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists || doc.data() == null) {
        // Fallback profile
        final appUser = AppUser(
          uid: user.uid,
          name: user.displayName ?? '',
          email: hiddenEmail,
          username: normalized,
          role: 'member',
          createdAt: DateTime.now(),
        );
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(appUser.toMap());
        return appUser;
      }

      return AppUser.fromMap(doc.id, doc.data()!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> logOut() async {
    await _auth.signOut();
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) throw const AuthException('Not signed in.');

    // Re-authenticate first.
    final credential = EmailAuthProvider.credential(
      email: firebaseUser.email!,
      password: currentPassword,
    );
    try {
      await firebaseUser.reauthenticateWithCredential(credential);
      await firebaseUser.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    }
  }

  @override
  Future<void> updateName(String name) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return;
    await firebaseUser.updateDisplayName(name.trim());
    await _firestore.collection('users').doc(firebaseUser.uid).update({
      'name': name.trim(),
    });
  }

  @override
  Future<void> updateLanguage(String language) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return;
    await _firestore.collection('users').doc(firebaseUser.uid).update({
      'language': language,
    });
  }

  @override
  Future<void> completePasswordChange(String newPassword) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) throw const AuthException('Not signed in.');
    try {
      await firebaseUser.updatePassword(newPassword);
      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .update({'mustChangePassword': false});
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    }
  }

  String _mapFirebaseAuthError(FirebaseAuthException e,
      {bool isSignUp = false}) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect username or password. Please try again.';
      case 'email-already-in-use':
        return isSignUp
            ? 'Username already taken.'
            : 'Incorrect username or password. Please try again.';
      case 'weak-password':
        return 'The password is too weak. Please use at least 6 characters.';
      case 'invalid-email':
        return 'Invalid username format.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network and retry.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again in a few moments.';
      default:
        return e.message ?? 'An unexpected authentication error occurred.';
    }
  }
}
