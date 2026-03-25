/// Pair of issued access and refresh tokens.
class AuthTokens {
  /// Creates an authentication token pair.
  AuthTokens({required this.accessToken, required this.refreshToken});

  /// Short-lived token used for authenticated API access.
  final String accessToken;

  /// Long-lived token used to obtain a new access token.
  final String refreshToken;
}
