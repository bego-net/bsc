import 'dart:async';

import '../models/app_user.dart';
import '../utils/auth_utils.dart';
import 'auth_repository.dart';
import 'firebase_auth_repository.dart';

/// In-memory implementation of [AuthRepository] for testing and offline development.
class FakeAuthRepository implements AuthRepository {
  /// Users keyed by uid.
  final Map<String, AppUser> _users = {};
  /// Passwords keyed by lowercase username.
  final Map<String, String> _passwords = {};
  final StreamController<String?> _authStreamController =
      StreamController<String?>.broadcast();

  String? _currentUserId;

  FakeAuthRepository({AppUser? initialUser}) {
    if (initialUser != null) {
      _users[initialUser.uid] = initialUser;
      final key = initialUser.username.isNotEmpty
          ? initialUser.username.toLowerCase()
          : initialUser.email.toLowerCase();
      _passwords[key] = 'password123';
      _currentUserId = initialUser.uid;
    }
  }

  /// Pre-registers a test user so they can log in immediately.
  void seedUser({
    required String name,
    required String username,
    required String password,
    String role = 'member',
    bool mustChangePassword = false,
  }) {
    final uid = 'user_${username.hashCode.abs()}';
    _users[uid] = AppUser(
      uid: uid,
      name: name.trim(),
      email: usernameToEmail(username.trim().toLowerCase()),
      username: username.trim().toLowerCase(),
      role: role,
      createdAt: DateTime.now(),
      currentBook: 'John',
      currentChapter: 1,
      verseFrom: 1,
      verseTo: 1,
      reminderTime: '07:00',
      mustChangePassword: mustChangePassword,
    );
    _passwords[username.trim().toLowerCase()] = password;
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
    required String username,
    required String password,
  }) async {
    if (password.length < 6) {
      throw const AuthException(
          'The password is too weak. Please use at least 6 characters.');
    }
    final normalized = username.trim().toLowerCase();
    if (_passwords.containsKey(normalized)) {
      throw const AuthException('Username already taken.');
    }

    final uid = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final user = AppUser(
      uid: uid,
      name: name.trim(),
      email: usernameToEmail(normalized),
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

    _users[uid] = user;
    _passwords[normalized] = password;
    _currentUserId = uid;
    _authStreamController.add(uid);
    return user;
  }

  @override
  Future<AppUser> logIn({
    required String username,
    required String password,
  }) async {
    final normalized = username.trim().toLowerCase();
    final storedPassword = _passwords[normalized];

    if (storedPassword == null || storedPassword != password) {
      throw const AuthException(
          'Incorrect username or password. Please try again.');
    }

    final user = _users.values.firstWhere(
      (u) => u.username.toLowerCase() == normalized,
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

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_currentUserId == null) throw const AuthException('Not signed in.');
    final user = _users[_currentUserId]!;
    final key = user.username.toLowerCase();
    if (_passwords[key] != currentPassword) {
      throw const AuthException('Current password is incorrect.');
    }
    if (newPassword.length < 6) {
      throw const AuthException(
          'The password is too weak. Please use at least 6 characters.');
    }
    _passwords[key] = newPassword;
  }

  @override
  Future<void> updateName(String name) async {
    if (_currentUserId == null) return;
    final user = _users[_currentUserId]!;
    _users[_currentUserId!] = user.copyWith(name: name.trim());
  }

  @override
  Future<void> completePasswordChange(String newPassword) async {
    if (_currentUserId == null) throw const AuthException('Not signed in.');
    if (newPassword.length < 6) {
      throw const AuthException(
          'The password is too weak. Please use at least 6 characters.');
    }
    final user = _users[_currentUserId]!;
    final key = user.username.toLowerCase();
    _passwords[key] = newPassword;
    _users[_currentUserId!] =
        user.copyWith(mustChangePassword: false);
  }

  void dispose() {
    _authStreamController.close();
  }
}
