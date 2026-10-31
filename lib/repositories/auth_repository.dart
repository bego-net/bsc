import '../models/app_user.dart';

/// Abstract authentication repository interface.
abstract class AuthRepository {
  /// Stream of current user's UID or null if not signed in.
  Stream<String?> get authStateChanges;

  /// Current user ID if signed in.
  String? get currentUserId;

  /// Loads the profile of the current user.
  Future<AppUser?> getCurrentUser();

  /// Registers a new user with username and password, setting role to 'member'.
  Future<AppUser> signUp({
    required String name,
    required String username,
    required String password,
  });

  /// Signs in an existing user with username and password.
  Future<AppUser> logIn({
    required String username,
    required String password,
  });

  /// Signs out the current user.
  Future<void> logOut();

  /// Re-authenticates and changes the password.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Updates the display name in the profile.
  Future<void> updateName(String name);

  /// Completes a forced password change (no re-auth needed, sets mustChangePassword=false).
  Future<void> completePasswordChange(String newPassword);
}
