import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../repositories/auth_repository.dart';

/// Manages authentication state, current user profile, and sign-in lifecycle.
class AuthState extends ChangeNotifier {
  final AuthRepository _repo;
  StreamSubscription<String?>? _authSubscription;

  AppUser? _user;
  bool _isLoading = true;
  String? _errorMessage;

  AuthState({required AuthRepository authRepository})
      : _repo = authRepository {
    _init();
  }

  AppUser? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;
  String get userRole => _user?.role ?? 'member';
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get mustChangePassword => _user?.mustChangePassword ?? false;

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _repo.getCurrentUser();
    } catch (e) {
      debugPrint('Failed to load current user: $e');
    }

    _isLoading = false;
    notifyListeners();

    _authSubscription = _repo.authStateChanges.listen((uid) async {
      if (uid == null) {
        _user = null;
        notifyListeners();
      } else {
        _user = await _repo.getCurrentUser();
        notifyListeners();
      }
    });
  }

  /// Registers a new user.
  Future<bool> signUp({
    required String name,
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _repo.signUp(
        name: name,
        username: username,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logs in an existing user.
  Future<bool> logIn({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _repo.logIn(
        username: username,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Signs out the current user.
  Future<void> logOut() async {
    _isLoading = true;
    notifyListeners();

    await _repo.logOut();
    _user = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Re-authenticates and changes the password; returns true on success.
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _errorMessage = null;
    notifyListeners();
    try {
      await _repo.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Updates the user's display name.
  Future<bool> updateName(String name) async {
    _errorMessage = null;
    try {
      await _repo.updateName(name);
      if (_user != null) {
        _user = _user!.copyWith(name: name.trim());
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Completes a forced password change and clears mustChangePassword.
  Future<bool> completePasswordChange(String newPassword) async {
    _errorMessage = null;
    notifyListeners();
    try {
      await _repo.completePasswordChange(newPassword);
      if (_user != null) {
        _user = _user!.copyWith(mustChangePassword: false);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Updates local user object when currently studying portion or settings change.
  void updateLocalProfile({
    String? name,
    String? currentBook,
    int? currentChapter,
    int? currentVerse,
    String? reminderTime,
  }) {
    if (_user == null) return;
    _user = _user!.copyWith(
      name: name,
      currentBook: currentBook,
      currentChapter: currentChapter,
      currentVerse: currentVerse,
      reminderTime: reminderTime,
    );
    notifyListeners();
  }

  /// Clears active error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
