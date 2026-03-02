import 'package:acanthis/acanthis.dart';

/// Validation schemas for category create and update operations.
class CategoryValidators {
  CategoryValidators._();

  /// Schema for validating category creation payloads.
  static AcanthisMap<dynamic> get createSchema => object({
    'name': string().min(3).max(100).toUpperCase(),
    'description': string().min(3).max(200).toUpperCase().nullable(),
    'storeId': string().uuid(),
    'imageUrl': string().url().nullable(),
  });

  /// Schema for validating category update payloads.
  static AcanthisMap<dynamic> get updateSchema => object({
    'name': string().min(3).max(100).toUpperCase().nullable(),
    'description': string().min(3).max(200).toUpperCase().nullable(),
    'isActive': boolean().nullable(),
    'imageUrl': string().url().nullable(),
  });
}
