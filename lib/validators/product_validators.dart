import 'package:acanthis/acanthis.dart';

/// Validation schemas for product create and update operations.
class ProductValidators {
  ProductValidators._();

  /// Schema for validating product creation payloads.
  static AcanthisMap<dynamic> get createSchema => object({
    'name': string().min(3).max(100).toUpperCase(),
    'description': string().min(3).max(200).toUpperCase().nullable(),
    'basePrice': number().positive(),
    'sellingPrice': number().positive(),
    'storeId': string().uuid(),
    'categoryId': string().uuid(),
    'counterId': string().uuid(),
    'imageUrl': string().url().nullable(),
    'sku': string().min(1).max(50).nullable(),
  });

  /// Schema for validating product update payloads.
  static AcanthisMap<dynamic> get updateSchema => object({
    'name': string().min(3).max(100).toUpperCase().nullable(),
    'description': string().min(3).max(200).toUpperCase().nullable(),
    'basePrice': number().positive().nullable(),
    'sellingPrice': number().positive().nullable(),
    'categoryId': string().uuid().nullable(),
    'counterId': string().uuid().nullable(),
    'imageUrl': string().url().nullable(),
    'sku': string().min(1).max(50).nullable(),
    'isActive': boolean().nullable(),
  });
}
