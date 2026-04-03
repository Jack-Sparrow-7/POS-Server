import 'package:acanthis/acanthis.dart';

/// Validators for store-related operations.
class StoreValidators {
  const StoreValidators._();

  /// Validates the request body for creating a new store.
  static AcanthisMap<dynamic> get createValidator => object({
    'tenantId': string().uuid(),
    'name': string().min(2).max(255),
    'slug': string().min(2).max(100),
    'description': string().max(1000).nullable(),
    'address': string().max(1000).nullable(),
    'city': string().max(100).nullable(),
    'state': string().max(100).nullable(),
    'pincode': string().max(10).nullable(),
    'phone': string().max(20).nullable(),
    'gstin': string().max(15).nullable(),
  });

  /// Validates the request body for updating admin-governed store controls.
  static AcanthisMap<dynamic> get updateValidator => object({
    'subscriptionStatus': string().nullable(),
    'subscriptionStartedAt': string().nullable().nullable(),
    'subscriptionExpiresAt': string().nullable().nullable(),
    'trialExpiresAt': string().nullable().nullable(),
    'phonepeClientId': string().max(255).nullable().nullable(),
    'phonepeClientVersion': integer().nullable(),
    'phonepeClientSecret': string().max(255).nullable().nullable(),
    'phonepeConfigured': boolean().nullable(),
    'gstEnabled': boolean().nullable(),
    'isOpen': boolean().nullable(),
    'isActive': boolean().nullable(),
  });
}
