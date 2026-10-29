import 'dart:async';

import '../models/app_user.dart';
import 'auth_repository.dart';
import 'firebase_auth_repository.dart';

/// In-memory implementation of [AuthRepository] for testing and offline development.
class FakeAuthRepository implements AuthRepository {
  final Map<String, AppUser> _users = {};
  final Map<String, String> _passwords = {};
  final StreamController<String?> _authStreamController =
      StreamController<String?>.broadcast();

  String? _currentUserId;

  FakeAuthRepository({AppUser? initialUser}) {
    if (initialUser != null) {
      _users[initialUser.uid] = initialUser;
      _passwords[initialUser.email] = 'password123';
      _currentUserId = initialUser.uid;
    }
  }

  @override
  Stream<String?> get authStateChanges => _authStreamController.stream;

  @override
  String? get currentUserId => _currentUserId;

  @override
  Future<AppUser?> getCurrentUser() async {
    if (_currentUserId == null) return null;
    return _users[_currentUserId];
  }

  @override
  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    if (password.length < 6) {
      throw const AuthException('The password is too weak. Please use at least 6 characters.');
    }
    if (_passwords.containsKey(email.trim().toLowerCase())) {
      throw const AuthException('This email is already in use by another account.');
    }

    final uid = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final user = AppUser(
      uid: uid,
      name: name.trim(),
      email: email.trim(),
      role: 'member', // Always member on signup
      createdAt: DateTime.now(),
      currentBook: 'John',
      currentChapter: 1,
      currentVerse: 1,
      reminderTime: '07:00',
    );

    _users[uid] = user;
    _passwords[email.trim().toLowerCase()] = password;
    _currentUserId = uid;
    _authStreamController.add(uid);
    return user;
  }

  @override
  Future<AppUser> logIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final storedPassword = _passwords[normalizedEmail];

    if (storedPassword == null) {
      throw const AuthException('No account found with this email.');
    }
    if (storedPassword != password) {
      throw const AuthException('Incorrect email or password. Please try again.');
    }

    final user = _users.values.firstWhere(
      (u) => u.email.toLowerCase() == normalizedEmail,
    );
    _currentUserId = user.uid;
    _authStreamController.add(user.uid);
    return user;
  }

  @override
  Future<void> logOut() async {
    _currentUserId = null;
    _authStreamController.add(null);
  }

  void dispose() {
    _authStreamController.close();
  }
}
