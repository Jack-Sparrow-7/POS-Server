import 'package:acanthis/acanthis.dart';

/// Validators for counter-related operations.
class CounterValidators {
  const CounterValidators._();

  /// Validates the request body for creating a counter.
  static AcanthisMap<dynamic> get createValidator => object({
    'storeId': string().uuid(),
    'name': string().min(2).max(100),
    'description': string().max(500).nullable(),
    'sortOrder': integer().nullable(),
  });

  /// Validates the request body for updating a counter.
  static AcanthisMap<dynamic> get updateValidator => object({
    'name': string().min(2).max(100).nullable(),
    'description': string().max(500).nullable().nullable(),
    'sortOrder': integer().nullable(),
    'isActive': boolean().nullable(),
  });
}
