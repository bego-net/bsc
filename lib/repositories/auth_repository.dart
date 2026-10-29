import '../models/app_user.dart';

/// Abstract authentication repository interface.
abstract class AuthRepository {
  /// Stream of current user's UID or null if not signed in.
  Stream<String?> get authStateChanges;

  /// Current user ID if signed in.
  String? get currentUserId;

  /// Loads the profile of the current user.
  Future<AppUser?> getCurrentUser();

  /// Registers a new user with email and password, setting role to 'member'.
  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  });

  /// Signs in an existing user with email and password.
  Future<AppUser> logIn({
    required String email,
    required String password,
  });

  /// Signs out the current user.
  Future<void> logOut();
}
