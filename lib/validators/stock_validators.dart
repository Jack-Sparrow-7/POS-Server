import 'package:acanthis/acanthis.dart';

/// Validation schemas for stock update operations.
class StockValidators {
  StockValidators._();

  /// Schema for validating stock update payloads.
  static AcanthisMap<dynamic> get updateSchema => object({
    'quantity': number().nonNegative().nullable(),
    'lowStockThreshold': number().nonNegative().nullable(),
  });
}
