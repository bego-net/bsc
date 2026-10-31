// Shared utilities for username-based authentication.

/// The domain used to build a hidden Firebase-compatible email from a username.
/// Keep this constant in ONE place so changing it is trivial.
const String kEmailDomain = 'biblestudy.invalid';

/// Converts a username to a hidden Firebase Auth email.
String usernameToEmail(String username) => '$username@$kEmailDomain';

/// Returns true if [s] is a valid username:
/// 3–20 lowercase letters, digits, or underscores.
bool isValidUsername(String s) =>
    RegExp(r'^[a-z0-9_]{3,20}$').hasMatch(s);
