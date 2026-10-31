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
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _repo.signUp(
        name: name,
        email: email,
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
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _repo.logIn(
        email: email,
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

  /// Updates local user object when currently studying portion changes.
  void updateLocalProfile({
    String? currentBook,
    int? currentChapter,
    int? currentVerse,
    String? reminderTime,
  }) {
    if (_user == null) return;
    _user = _user!.copyWith(
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
