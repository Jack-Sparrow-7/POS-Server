import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:pos_backend/config/env.dart';

/// Utility methods for generating and verifying JWT tokens.
class JwtService {
  JwtService._();

  /// Generates a signed JWT for the given user identifier.
  static String generateToken({
    required String userId,
    required String type,
    required String tokenKind,
    required Duration expiresIn,
    int? tokenVersion,
  }) {
    final payload = <String, dynamic>{
      'sub': userId,
      'type': type,
      'kind': tokenKind,
    };
    if (tokenVersion != null) {
      payload['tv'] = tokenVersion;
    }

    final jwt = JWT(payload);

    return jwt.sign(
      SecretKey(Env.jwtSecret),
      expiresIn: expiresIn,
    );
  }

  /// Generates a short-lived access token.
  static String generateAccessToken({
    required String userId,
    required String type,
    int? tokenVersion,
  }) {
    return generateToken(
      userId: userId,
      type: type,
      tokenVersion: tokenVersion,
      tokenKind: 'access',
      expiresIn: Env.jwtExpiry,
    );
  }

  /// Generates a long-lived refresh token.
  static String generateRefreshToken({
    required String userId,
    required String type,
    int? tokenVersion,
  }) {
    return generateToken(
      userId: userId,
      type: type,
      tokenVersion: tokenVersion,
      tokenKind: 'refresh',
      expiresIn: Env.refreshJwtExpiry,
    );
  }

  /// Verifies a JWT and returns its payload map.
  static Map<String, dynamic> verifyToken({
    required String token,
  }) {
    final jwt = JWT.verify(
      token,
      SecretKey(Env.jwtSecret),
    );

    return Map<String, dynamic>.from(jwt.payload as Map);
  }
}
