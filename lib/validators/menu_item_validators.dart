import 'package:acanthis/acanthis.dart';

/// Validators for menu-item-related operations.
class MenuItemValidators {
  const MenuItemValidators._();

  /// Validates query parameters for listing menu items.
  static AcanthisMap<dynamic> get listQueryValidator => object({
    'storeId': string().uuid().nullable(),
    'categoryId': string().uuid().nullable(),
    'counterId': string().uuid().nullable(),
    'isAvailable': boolean().nullable(),
  });

  /// Validates the request body for creating a menu item.
  static AcanthisMap<dynamic> get createValidator => object({
    'storeId': string().uuid(),
    'name': string().min(2).max(255),
    'description': string().max(1000).nullable(),
    'categoryId': string().uuid().nullable(),
    'counterId': string().uuid().nullable(),
    'costPrice': number().gte(0),
    'price': number().gte(0),
    'gstPercent': number().gte(0),
    'hsnCode': string().max(20).nullable(),
    'isAvailable': boolean().nullable(),
    'stockCount': integer().nullable(),
    'trackStock': boolean().nullable(),
    'sortOrder': integer().nullable(),
    'imageUrl': string().max(500).nullable(),
  });

  /// Validates the request body for updating a menu item.
  static AcanthisMap<dynamic> get updateValidator => object({
    'name': string().min(2).max(255).nullable(),
    'description': string().max(1000).nullable().nullable(),
    'categoryId': string().uuid().nullable().nullable(),
    'counterId': string().uuid().nullable().nullable(),
    'costPrice': number().gte(0).nullable(),
    'price': number().gte(0).nullable(),
    'gstPercent': number().gte(0).nullable(),
    'hsnCode': string().max(20).nullable().nullable(),
    'isAvailable': boolean().nullable(),
    'stockCount': integer().nullable().nullable(),
    'trackStock': boolean().nullable(),
    'sortOrder': integer().nullable(),
    'imageUrl': string().max(500).nullable().nullable(),
  });
}
