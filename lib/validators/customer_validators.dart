import 'package:acanthis/acanthis.dart';

/// Validation schemas for customer authentication payloads.
class CustomerValidators {
  CustomerValidators._();

  /// Validation schema for customer registration payloads.
  static AcanthisMap<dynamic> get registerSchema => object({
    'name': string().min(3).max(100).toUpperCase(),
    'mobileNumber': string().length(10),
    'email': string().email(),
    'password': string().min(6).max(128),
  });

  /// Validation schema for customer login payloads.
  static AcanthisMap<dynamic> get loginSchema => object({
    'email': string().email(),
    'password': string().min(6).max(128),
  });
}
