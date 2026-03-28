import 'package:acanthis/acanthis.dart';

/// Validators for platform admin operations.
class PlatformAdminValidators {
  const PlatformAdminValidators._();

  /// Validates the login request body.
  static AcanthisMap<dynamic> get loginValidator => object({
    'email': string().email(),
    'password': string().min(6),
  });
}
