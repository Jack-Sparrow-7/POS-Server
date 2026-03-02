import 'package:acanthis/acanthis.dart';

/// Validation schemas for counter create and update operations.
class CounterValidators {
  CounterValidators._();

  /// Schema for validating counter creation payloads.
  static AcanthisMap<dynamic> get createSchema => object({
    'name': string().min(3).max(100).toUpperCase(),
    'description': string().min(3).max(200).toUpperCase().nullable(),
    'storeId': string().uuid(),
  });

  /// Schema for validating counter update payloads.
  static AcanthisMap<dynamic> get updateSchema => object({
    'name': string().min(3).max(100).toUpperCase().nullable(),
    'description': string().min(3).max(200).toUpperCase().nullable(),
    'isActive': boolean().nullable(),
  });
}
