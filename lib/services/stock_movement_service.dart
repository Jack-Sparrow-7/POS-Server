import 'package:loxia/loxia.dart';
import 'package:pos_backend/enums/stock_change_reason.dart';
import 'package:pos_backend/models/stock/stock.dart';
import 'package:pos_backend/models/stock_movement/stock_movement.dart';

/// Result of a stock movement operation.
class StockMovementResult {
  /// Creates a result with updated stock and inserted movement.
  const StockMovementResult({
    required this.stock,
    required this.movement,
  });

  /// Updated stock row.
  final Stock stock;

  /// Inserted movement row.
  final StockMovement movement;
}

/// Known business failures for stock movements.
enum StockMovementErrorCode {
  /// Stock row for given store/product not found.
  notFound,

  /// Movement would drop stock below zero.
  insufficientStock,
}

/// Exception wrapper for movement business failures.
class StockMovementException implements Exception {
  /// Creates a typed stock movement exception.
  const StockMovementException(this.code);

  /// Failure code.
  final StockMovementErrorCode code;
}

/// Centralized stock movement engine used by all stock mutation endpoints.
class StockMovementService {
  StockMovementService._();

  /// Applies one movement with row lock, no-negative rule and audit log write.
  static Future<StockMovementResult> apply({
    required DataSource dataSource,
    required String merchantId,
    required String storeId,
    required String productId,
    required StockChangeReason reason,
    required int quantity,
    String? note,
    bool resetAll = false,
  }) async {
    return dataSource.transaction<StockMovementResult>((tx) async {
      final stockRepo = tx.getRepository<Stock>();
      final movementRepo = tx.getRepository<StockMovement>();

      final rows = await stockRepo.engine.query(
        '''
        SELECT s."id", s."quantity"
        FROM "stock" s
        INNER JOIN "stores" st ON st."id" = s."store_id"
        WHERE s."store_id" = ? AND s."product_id" = ? AND st."merchant_id" = ?
        FOR UPDATE
        ''',
        [storeId, productId, merchantId],
      );

      if (rows.isEmpty) {
        throw const StockMovementException(StockMovementErrorCode.notFound);
      }

      final row = rows.first;
      final stockId = row['id'] as String;
      final currentQuantity = row['quantity'] as int;
      final quantityChange = resetAll
          ? -currentQuantity
          : reason == StockChangeReason.IN
          ? quantity
          : -quantity;
      final nextQuantity = currentQuantity + quantityChange;

      if (nextQuantity < 0) {
        throw const StockMovementException(
          StockMovementErrorCode.insufficientStock,
        );
      }

      final updatedStock = await stockRepo.save(
        StockPartial(
          id: stockId,
          quantity: nextQuantity,
        ),
      );

      final movement = await movementRepo.save(
        StockMovementPartial(
          stockId: stockId,
          storeId: storeId,
          productId: productId,
          reason: reason,
          quantityBefore: currentQuantity,
          quantityChange: quantityChange,
          quantityAfter: nextQuantity,
          note: note,
        ),
      );

      return StockMovementResult(
        stock: updatedStock,
        movement: movement,
      );
    });
  }
}
