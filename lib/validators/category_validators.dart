import 'package:acanthis/acanthis.dart';

/// Validators for category-related operations.
class CategoryValidators {
  const CategoryValidators._();

  /// Validates the request body for creating a category.
  static AcanthisMap<dynamic> get createValidator => object({
    'storeId': string().uuid(),
    'name': string().min(2).max(100),
    'imageUrl': string().max(500).nullable(),
    'sortOrder': integer().nullable(),
  });

  /// Validates the request body for updating a category.
  static AcanthisMap<dynamic> get updateValidator => object({
    'name': string().uuid().min(2).max(100).nullable(),
    'imageUrl': string().max(500).nullable().nullable(),
    'sortOrder': integer().nullable(),
    'isActive': boolean().nullable(),
  });
}
