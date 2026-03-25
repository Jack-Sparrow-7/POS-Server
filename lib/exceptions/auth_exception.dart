/// Exception thrown when authentication token generation or validation fails.
class AuthException implements Exception {
  /// Creates an authentication exception with a human-readable message.
  AuthException({required this.message});

  /// Error message describing the authentication failure.
  final String message;
}
