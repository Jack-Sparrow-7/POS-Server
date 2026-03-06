import 'package:acanthis/acanthis.dart';
import 'package:pos_backend/enums/stock_change_reason.dart';

/// Validation schemas for stock movement operations.
class StockValidators {
  StockValidators._();

  /// Schema for adding stock.
  static AcanthisMap<dynamic> get addSchema => object({
    'storeId': string().uuid(),
    'productId': string().uuid(),
    'quantity': number().positive(),
    'note': string().max(250).nullable(),
  });

  /// Schema for reducing stock as manual adjustment.
  static AcanthisMap<dynamic> get reduceSchema => object({
    'storeId': string().uuid(),
    'productId': string().uuid(),
    'quantity': number().positive(),
    'reason': string().toUpperCase().contained([
      StockChangeReason.WASTAGE.name,
      StockChangeReason.ADJUSTMENT.name,
    ]),
    'note': string().max(250).nullable(),
  });

  /// Schema for resetting stock to zero due to wastage.
  static AcanthisMap<dynamic> get resetSchema => object({
    'storeId': string().uuid(),
    'productId': string().uuid(),
  });
}
