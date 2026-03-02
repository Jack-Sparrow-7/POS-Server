import 'package:acanthis/acanthis.dart';
import 'package:pos_backend/enums/store_type.dart';

/// Validation schemas for store-related payloads.
class StoreValidators {
  StoreValidators._();

  /// Validation schema for store creation payloads.
  static AcanthisMap<dynamic> get createSchema => object({
    'name': string().min(3).max(100).toUpperCase(),
    'email': string().email(),
    'whatsappNumber': string().length(10).nullable(),
    'type': string().toUpperCase().contained(
      StoreType.values.map((e) => e.name).toList(),
    ),
  });

  /// Validation schema for store updation payloads.
  static AcanthisMap<dynamic> get updateSchema => object({
    'name': string().min(3).max(100).toUpperCase().nullable(),
    'email': string().email().nullable(),
    'whatsappNumber': string().length(10).nullable(),
    'type': string()
        .toUpperCase()
        .contained(StoreType.values.map((e) => e.name).toList())
        .nullable(),
  });
}
