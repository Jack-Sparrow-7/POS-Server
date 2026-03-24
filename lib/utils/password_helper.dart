import 'package:bcrypt/bcrypt.dart';

/// Provides password hashing, verification, and validation helpers.
class PasswordHelper {
  PasswordHelper._();

  /// Hashes a plain-text password using bcrypt.
  static String hash(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt(logRounds: 12));
  }

  /// Verifies a plain-text password against a bcrypt hash.
  static bool verify(String password, String hash) {
    return BCrypt.checkpw(password, hash);
  }

  /// Validates password strength and returns an error message when invalid.
  static String? validate(String password) {
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (!password.contains(RegExp('[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!password.contains(RegExp('[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }
}
