import 'package:acanthis/acanthis.dart';

/// Validators for tenant-related operations.
class TenantValidators {
  const TenantValidators._();

  /// Validates the request body for creating a new tenant.
  static AcanthisMap<dynamic> get createValidator => object({
    'name': string().min(2).max(100),
    'email': string().email(),
    'phone': string().min(10).max(20),
    'address': string().max(500).nullable(),
    'city': string().max(100).nullable(),
    'state': string().max(100).nullable(),
    'pincode': string().max(10).nullable(),
  });

  /// Validates the request body for updating tenant details.
  static AcanthisMap<dynamic> get updateValidator => object({
    'name': string().min(2).max(100).nullable(),
    'phone': string().min(10).max(20).nullable(),
    'address': string().max(500).nullable().nullable(),
    'city': string().max(100).nullable().nullable(),
    'state': string().max(100).nullable().nullable(),
    'pincode': string().max(10).nullable().nullable(),
    'isActive': boolean().nullable(),
  });
}
