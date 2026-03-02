import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:pos_backend/config/env.dart';

/// Utility methods for generating and verifying JWT tokens.
class JwtService {
  JwtService._();

  /// Generates a signed JWT for the given user identifier.
  static String generateToken({
    required String userId,
    required String type,
  }) {
    final jwt = JWT({
      'sub': userId,
      'type': type,
    });

    return jwt.sign(
      SecretKey(Env.jwtSecret),
      expiresIn: Env.jwtExpiry,
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
