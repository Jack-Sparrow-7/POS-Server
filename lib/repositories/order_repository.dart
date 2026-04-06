import 'package:postgres/postgres.dart';

/// Thrown when an order status update violates allowed state transitions.
class InvalidOrderStatusTransitionException implements Exception {
  /// Creates a new [InvalidOrderStatusTransitionException].
  const InvalidOrderStatusTransitionException();
}

/// Repository for cashier order creation operations.
class OrderRepository {
  /// Creates a new instance of [OrderRepository].
  OrderRepository({required Pool<String> pool}) : _pool = pool;

  final Pool<String> _pool;

  static const Map<String, Set<String>> _allowedStatusTransitions = {
    'pending': {'confirmed', 'cancelled'},
    'confirmed': {'ready', 'cancelled'},
    'ready': {'completed', 'cancelled'},
    'completed': {},
    'cancelled': {},
  };

  /// Returns all orders for a cashier-scoped store, with optional filters.
  Future<List<Map<String, dynamic>>> fetchAllForCashierStore({
    required String tenantId,
    required String storeId,
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final result = await _pool.execute(
      Sql.named('''
        SELECT o.id,
               o.store_id,
               o.customer_id,
               o.cashier_id,
               o.order_number,
               o.source,
               o.status,
               o.subtotal,
               o.gst_amount,
               o.discount_amount,
               o.total,
               o.payment_method,
               o.payment_status,
               o.notes,
               o.created_at,
               o.updated_at
        FROM orders o
        INNER JOIN stores s ON s.id = o.store_id
        WHERE s.tenant_id = @tenantId
          AND o.store_id = @storeId
          AND (@status IS NULL OR o.status = @status)
          AND (@fromDate IS NULL OR o.created_at >= @fromDate)
          AND (@toDate IS NULL OR o.created_at <= @toDate)
        ORDER BY o.created_at DESC
      '''),
      parameters: {
        'tenantId': tenantId,
        'storeId': storeId,
        'status': status,
        'fromDate': fromDate,
        'toDate': toDate,
      },
    );

    return result.map((row) {
      final map = row.toColumnMap();
      return {
        'id': map['id'] as String,
        'storeId': map['store_id'] as String,
        'customerId': map['customer_id'] as String?,
        'cashierId': map['cashier_id'] as String?,
        'orderNumber': map['order_number'] as String,
        'source': map['source'] as String,
        'status': map['status'] as String,
        'subtotal': map['subtotal'] as num,
        'gstAmount': map['gst_amount'] as num,
        'discountAmount': map['discount_amount'] as num,
        'total': map['total'] as num,
        'paymentMethod': map['payment_method'] as String?,
        'paymentStatus': map['payment_status'] as String,
        'notes': map['notes'] as String?,
        'createdAt': (map['created_at'] as DateTime).toIso8601String(),
        'updatedAt': (map['updated_at'] as DateTime).toIso8601String(),
      };
    }).toList();
  }

  /// Returns one order for a cashier-scoped store, including order items.
  Future<Map<String, dynamic>?> findByIdForCashierStore({
    required String id,
    required String tenantId,
    required String storeId,
  }) async {
    final orderResult = await _pool.execute(
      Sql.named('''
        SELECT o.id,
               o.store_id,
               o.customer_id,
               o.cashier_id,
               o.order_number,
               o.source,
               o.status,
               o.subtotal,
               o.gst_amount,
               o.discount_amount,
               o.total,
               o.payment_method,
               o.payment_status,
               o.notes,
               o.confirmed_at,
               o.ready_at,
               o.completed_at,
               o.cancelled_at,
               o.created_at,
               o.updated_at
        FROM orders o
        INNER JOIN stores s ON s.id = o.store_id
        WHERE o.id = @id
          AND s.tenant_id = @tenantId
          AND o.store_id = @storeId
        LIMIT 1
      '''),
      parameters: {
        'id': id,
        'tenantId': tenantId,
        'storeId': storeId,
      },
    );

    if (orderResult.isEmpty) {
      return null;
    }

    final orderMap = orderResult.first.toColumnMap();

    final itemsResult = await _pool.execute(
      Sql.named('''
        SELECT oi.id,
               oi.order_id,
               oi.menu_item_id,
               oi.item_name,
               oi.counter_name,
               oi.cost_price,
               oi.unit_price,
               oi.gst_percent,
               oi.quantity,
               oi.line_total,
               oi.gst_amount,
               oi.created_at
        FROM order_items oi
        WHERE oi.order_id = @orderId
        ORDER BY oi.created_at ASC, oi.id ASC
      '''),
      parameters: {'orderId': orderMap['id'] as String},
    );

    final items = itemsResult.map((row) {
      final itemMap = row.toColumnMap();
      return {
        'id': itemMap['id'] as String,
        'orderId': itemMap['order_id'] as String,
        'menuItemId': itemMap['menu_item_id'] as String?,
        'itemName': itemMap['item_name'] as String,
        'counterName': itemMap['counter_name'] as String?,
        'costPrice': itemMap['cost_price'] as num,
        'unitPrice': itemMap['unit_price'] as num,
        'gstPercent': itemMap['gst_percent'] as num,
        'quantity': itemMap['quantity'] as int,
        'lineTotal': itemMap['line_total'] as num,
        'gstAmount': itemMap['gst_amount'] as num,
        'createdAt': (itemMap['created_at'] as DateTime).toIso8601String(),
      };
    }).toList();

    return {
      'id': orderMap['id'] as String,
      'storeId': orderMap['store_id'] as String,
      'customerId': orderMap['customer_id'] as String?,
      'cashierId': orderMap['cashier_id'] as String?,
      'orderNumber': orderMap['order_number'] as String,
      'source': orderMap['source'] as String,
      'status': orderMap['status'] as String,
      'subtotal': orderMap['subtotal'] as num,
      'gstAmount': orderMap['gst_amount'] as num,
      'discountAmount': orderMap['discount_amount'] as num,
      'total': orderMap['total'] as num,
      'paymentMethod': orderMap['payment_method'] as String?,
      'paymentStatus': orderMap['payment_status'] as String,
      'notes': orderMap['notes'] as String?,
      'confirmedAt': (orderMap['confirmed_at'] as DateTime?)?.toIso8601String(),
      'readyAt': (orderMap['ready_at'] as DateTime?)?.toIso8601String(),
      'completedAt': (orderMap['completed_at'] as DateTime?)?.toIso8601String(),
      'cancelledAt': (orderMap['cancelled_at'] as DateTime?)?.toIso8601String(),
      'createdAt': (orderMap['created_at'] as DateTime).toIso8601String(),
      'updatedAt': (orderMap['updated_at'] as DateTime).toIso8601String(),
      'items': items,
    };
  }

  /// Updates order status for a cashier-scoped store with guarded transitions.
  Future<Map<String, dynamic>?> updateStatusForCashierStore({
    required String id,
    required String tenantId,
    required String storeId,
    required String nextStatus,
  }) async {
    final currentStateResult = await _pool.execute(
      Sql.named('''
        SELECT o.status
        FROM orders o
        INNER JOIN stores s ON s.id = o.store_id
        WHERE o.id = @id
          AND s.tenant_id = @tenantId
          AND o.store_id = @storeId
        LIMIT 1
      '''),
      parameters: {
        'id': id,
        'tenantId': tenantId,
        'storeId': storeId,
      },
    );

    if (currentStateResult.isEmpty) {
      return null;
    }

    final currentStatus =
        currentStateResult.first.toColumnMap()['status'] as String;
    final allowedNext = _allowedStatusTransitions[currentStatus] ?? {};
    if (!allowedNext.contains(nextStatus)) {
      throw const InvalidOrderStatusTransitionException();
    }

    final timestampColumn = switch (nextStatus) {
      'confirmed' => 'confirmed_at',
      'ready' => 'ready_at',
      'completed' => 'completed_at',
      'cancelled' => 'cancelled_at',
      _ => throw const InvalidOrderStatusTransitionException(),
    };

    final updateResult = await _pool.execute(
      Sql.named('''
        UPDATE orders o
        SET status = @nextStatus,
            updated_at = NOW(),
            $timestampColumn = COALESCE($timestampColumn, NOW())
        FROM stores s
        WHERE o.id = @id
          AND s.id = o.store_id
          AND s.tenant_id = @tenantId
          AND o.store_id = @storeId
        RETURNING o.id
      '''),
      parameters: {
        'id': id,
        'tenantId': tenantId,
        'storeId': storeId,
        'nextStatus': nextStatus,
      },
    );

    if (updateResult.isEmpty) {
      return null;
    }

    return findByIdForCashierStore(
      id: id,
      tenantId: tenantId,
      storeId: storeId,
    );
  }

  /// Persists a cashier order and its items in a single transaction.
  Future<Map<String, dynamic>?> createForCashier({
    required String tenantId,
    required String storeId,
    required String cashierId,
    required List<Map<String, dynamic>> items,
    required num subtotal,
    required num gstAmount,
    required num total,
    String? customerId,
    String? notes,
  }) async {
    return _pool.runTx((tx) async {
      final storeScopeResult = await tx.execute(
        Sql.named('''
          SELECT 1
          FROM stores
          WHERE id = @storeId
            AND tenant_id = @tenantId
          LIMIT 1
        '''),
        parameters: {
          'storeId': storeId,
          'tenantId': tenantId,
        },
      );

      if (storeScopeResult.isEmpty) {
        return null;
      }

      await tx.execute(
        Sql.named('''
          INSERT INTO store_order_sequences (store_id, last_sequence, sequence_date)
          VALUES (@storeId, 0, CURRENT_DATE)
          ON CONFLICT (store_id) DO NOTHING
        '''),
        parameters: {'storeId': storeId},
      );

      final seqResult = await tx.execute(
        Sql.named('''
          UPDATE store_order_sequences
          SET last_sequence = CASE
                WHEN sequence_date = CURRENT_DATE THEN last_sequence + 1
                ELSE 1
              END,
              sequence_date = CURRENT_DATE
          WHERE store_id = @storeId
          RETURNING last_sequence
        '''),
        parameters: {'storeId': storeId},
      );

      final sequence = seqResult.first.toColumnMap()['last_sequence'] as int;
      final utcNow = DateTime.now().toUtc();
      final datePrefix =
          '${utcNow.year.toString().padLeft(4, '0')}'
          '${utcNow.month.toString().padLeft(2, '0')}'
          '${utcNow.day.toString().padLeft(2, '0')}';
      final orderNumber =
          'ORD-$datePrefix-${sequence.toString().padLeft(4, '0')}';

      final orderInsertResult = await tx.execute(
        Sql.named('''
          INSERT INTO orders (
            store_id,
            customer_id,
            cashier_id,
            order_number,
            source,
            status,
            subtotal,
            gst_amount,
            discount_amount,
            total,
            payment_status,
            notes
          )
          VALUES (
            @storeId,
            @customerId,
            @cashierId,
            @orderNumber,
            'walk_in',
            'pending',
            @subtotal,
            @gstAmount,
            0,
            @total,
            'pending',
            @notes
          )
          RETURNING id,
                    order_number,
                    source,
                    status,
                    subtotal,
                    gst_amount,
                    discount_amount,
                    total,
                    payment_status,
                    notes,
                    created_at
        '''),
        parameters: {
          'storeId': storeId,
          'customerId': customerId,
          'cashierId': cashierId,
          'orderNumber': orderNumber,
          'subtotal': subtotal,
          'gstAmount': gstAmount,
          'total': total,
          'notes': notes,
        },
      );

      final orderRow = orderInsertResult.first.toColumnMap();
      final orderId = orderRow['id'] as String;

      for (final item in items) {
        await tx.execute(
          Sql.named('''
            INSERT INTO order_items (
              order_id,
              menu_item_id,
              item_name,
              counter_name,
              cost_price,
              unit_price,
              gst_percent,
              quantity,
              line_total,
              gst_amount
            )
            VALUES (
              @orderId,
              @menuItemId,
              @itemName,
              @counterName,
              0,
              @unitPrice,
              @gstPercent,
              @quantity,
              @lineTotal,
              @itemGstAmount
            )
          '''),
          parameters: {
            'orderId': orderId,
            'menuItemId': item['menuItemId'] as String,
            'itemName': item['itemName'] as String,
            'counterName': item['counterName'] as String?,
            'unitPrice': item['unitPrice'] as num,
            'gstPercent': item['gstPercent'] as num,
            'quantity': item['quantity'] as int,
            'lineTotal': item['lineTotal'] as num,
            'itemGstAmount': item['gstAmount'] as num,
          },
        );
      }

      return {
        'id': orderId,
        'storeId': storeId,
        'tenantId': tenantId,
        'cashierId': cashierId,
        'customerId': customerId,
        'orderNumber': orderRow['order_number'] as String,
        'source': orderRow['source'] as String,
        'status': orderRow['status'] as String,
        'subtotal': orderRow['subtotal'] as num,
        'gstAmount': orderRow['gst_amount'] as num,
        'discountAmount': orderRow['discount_amount'] as num,
        'total': orderRow['total'] as num,
        'paymentStatus': orderRow['payment_status'] as String,
        'notes': orderRow['notes'] as String?,
        'createdAt': (orderRow['created_at'] as DateTime).toIso8601String(),
        'items': items,
      };
    });
  }
}
