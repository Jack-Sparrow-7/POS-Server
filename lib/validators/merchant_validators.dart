import 'package:acanthis/acanthis.dart';

/// Validation schemas for merchant authentication payloads.
class MerchantValidators {
  MerchantValidators._();

  /// Validation schema for merchant registration payloads.
  static AcanthisMap<dynamic> get registerSchema => object({
    'name': string().min(3).max(100).toUpperCase(),
    'businessName': string().min(3).max(150).toUpperCase(),
    'mobileNumber': string().length(10),
    'email': string().email(),
    'password': string().min(6).max(128),
  });

  /// Validation schema for merchant login payloads.
  static AcanthisMap<dynamic> get loginSchema => object({
    'email': string().email(),
    'password': string().min(6).max(128),
  });

  /// Validation schema for merchant token refresh payloads.
  static AcanthisMap<dynamic> get refreshSchema => object({
    'refreshToken': string().min(10).nullable(),
  });

  /// Validation schema for merchant profile update payloads.
  static AcanthisMap<dynamic> get updateSchema => object({
    'name': string().min(3).max(100).toUpperCase().nullable(),
    'businessName': string().min(3).max(150).toUpperCase().nullable(),
    'mobileNumber': string().length(10).nullable(),
    'email': string().email().nullable(),
    'password': string().min(6).max(128).nullable(),
  });
} 
