import 'package:acanthis/acanthis.dart';

/// Validation schemas for terminal-related payloads.
class TerminalValidators {
  TerminalValidators._();

  /// Validation schema for Terminal registration payloads.
  static AcanthisMap<dynamic> get registerSchema => object({
    'name': string().min(3).max(100).toUpperCase(),
    'password': string().min(6).max(128),
    'storeId': string().uuid(),
  });

  /// Validation schema for Terminal login payloads.
  static AcanthisMap<dynamic> get loginSchema => object({
    'password': string().min(6).max(128),
    'terminalCode': string().upperCase().length(12).toUpperCase(),
  });

  /// Validation schema for terminal token refresh payloads.
  static AcanthisMap<dynamic> get refreshSchema => object({
    'refreshToken': string().min(10).nullable(),
  });

  /// Validation schema for Terminal updation payloads.
  static AcanthisMap<dynamic> get updateSchema => object({
    'name': string().min(3).max(100).toUpperCase().nullable(),
    'password': string().min(6).max(128).nullable(),
    'isActive': boolean().nullable(),
  });
}
