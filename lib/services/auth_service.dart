import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:pos_server/config/env.dart';
import 'package:pos_server/models/token_payload.dart';

/// Pair of issued access and refresh tokens.
class AuthTokens {
  /// Creates an authentication token pair.
  AuthTokens({required this.accessToken, required this.refreshToken});

  /// Short-lived token used for authenticated API access.
  final String accessToken;

  /// Long-lived token used to obtain a new access token.
  final String refreshToken;
}

/// Exception thrown when authentication token generation or validation fails.
class AuthException implements Exception {
  /// Creates an authentication exception with a human-readable message.
  AuthException({required this.message});

  /// Error message describing the authentication failure.
  final String message;
}

/// Handles authentication token generation.
class AuthService {
  AuthService._();

  /// Generates an access token for the provided token payload.
  String generateAccessToken(TokenPayload payload) {
    final jwt = JWT(payload.toMap(), issuer: 'pos-api');

    return jwt.sign(
      SecretKey(Env.jwtSecret),
      expiresIn: Duration(hours: Env.jwtExpiryHours),
    );
  }

  /// Generates a refresh token for the provided token payload.
  String generateRefreshToken(TokenPayload payload) {
    final jwt = JWT({
      'sub': payload.id,
      'role': payload.role.name,
      'type': 'refresh',
    }, issuer: 'pos-api');

    return jwt.sign(
      SecretKey(Env.jwtSecret),
      expiresIn: Duration(days: Env.jwtRefreshExpiryDays),
    );
  }

  /// Generates both access and refresh tokens for the provided payload.
  AuthTokens generateTokens(TokenPayload payload) {
    return AuthTokens(
      accessToken: generateAccessToken(payload),
      refreshToken: generateRefreshToken(payload),
    );
  }

  /// Verifies an access token and returns its decoded payload.
  TokenPayload verifyAccessToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(Env.jwtSecret));
      final map = jwt.payload as Map<String, dynamic>;
      if (map['type'] == 'refresh') {
        throw AuthException(
          message: 'Cannot use refresh token as access token',
        );
      }
      return TokenPayload.fromMap(map);
    } on JWTExpiredException {
      throw AuthException(message: 'Token expired');
    } on JWTException catch (e) {
      throw AuthException(message: 'Invalid token: ${e.message}');
    }
  }

  /// Verifies a refresh token and returns its decoded payload.
  TokenPayload verifyRefreshToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(Env.jwtSecret));
      final map = jwt.payload as Map<String, dynamic>;
      if (map['type'] != 'refresh') {
        throw AuthException(message: 'Invalid refresh token');
      }
      return TokenPayload.fromMap(map);
    } on JWTExpiredException {
      throw AuthException(
        message: 'Refresh token expired — please login again',
      );
    } on JWTException catch (e) {
      throw AuthException(message: 'Invalid token: ${e.message}');
    }
  }

  /// Extracts the bearer token value from an authorization header.
  String? extractBearerToken(String? authorization) {
    if (authorization == null || !authorization.startsWith('Bearer')) {
      return null;
    }

    return authorization.split(' ')[1];
  }
}
