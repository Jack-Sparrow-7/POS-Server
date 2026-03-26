import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:pos_server/config/env.dart';
import 'package:pos_server/exceptions/auth_exception.dart';
import 'package:pos_server/models/auth_tokens.dart';
import 'package:pos_server/models/token_payload.dart';

/// Handles authentication token generation.
class AuthService {
  AuthService._();

  /// Generates an access token for the provided token payload.
  static String generateAccessToken(TokenPayload payload) {
    final jwt = JWT(payload.toMap(), issuer: 'pos-api');

    return jwt.sign(
      SecretKey(Env.jwtSecret),
      expiresIn: Duration(hours: Env.jwtExpiryHours),
    );
  }

  /// Generates a refresh token for the provided token payload.
  static String generateRefreshToken(TokenPayload payload) {
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
  static AuthTokens generateTokens(TokenPayload payload) {
    return AuthTokens(
      accessToken: generateAccessToken(payload),
      refreshToken: generateRefreshToken(payload),
    );
  }

  /// Verifies an access token and returns its decoded payload.
  static TokenPayload verifyAccessToken(String token) {
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
  static TokenPayload verifyRefreshToken(String token) {
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
  static String? extractBearerToken(String? authorization) {
    if (authorization == null) {
      return null;
    }

    final parts = authorization.split(' ');
    if (parts.length != 2 || parts.first != 'Bearer' || parts.last.isEmpty) {
      return null;
    }

    return parts.last;
  }
  /// Extracts the access token value from an cookies.
  static String? extractAccessTokenFromCookies(String? cookieHeader) {
    if (cookieHeader == null) {
      return null;
    }

    for (final cookie in cookieHeader.split(';')) {
      final trimmedCookie = cookie.trim();
      if (trimmedCookie.startsWith('access_token=')) {
        return trimmedCookie.substring('access_token='.length);
      }
    }

    return null;
  }
}
