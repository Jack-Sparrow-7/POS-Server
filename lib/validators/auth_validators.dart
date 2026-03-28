import 'package:acanthis/acanthis.dart';

/// Validators for auth route payloads.
class AuthValidators {
  const AuthValidators._();

  /// Validates the login request body.
  static AcanthisMap<dynamic> get loginValidator => object({
    'email': string().email(),
    'password': string().min(6),
  });

  /// Validates the refresh request body.
  static AcanthisMap<dynamic> get refreshValidator => object({
    'refreshToken': string().min(1),
  });
}
