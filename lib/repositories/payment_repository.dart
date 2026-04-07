import 'package:postgres/postgres.dart';

/// Thrown when payment initiation is attempted for an order with non-pending
/// payment status.
class OrderPaymentNotPendingException implements Exception {
  /// Creates a new [OrderPaymentNotPendingException].
  const OrderPaymentNotPendingException();
}

/// Thrown when an order already has a pending payment initiation.
class PaymentAlreadyInitiatedException implements Exception {
  /// Creates a new [PaymentAlreadyInitiatedException].
  const PaymentAlreadyInitiatedException();
}

/// Repository for payment initiation operations.
class PaymentRepository {
  /// Creates a new [PaymentRepository].
  PaymentRepository({required Pool<String> pool}) : _pool = pool;

  final Pool<String> _pool;

  /// Syncs a payment status by merchant order id and propagates it to the
  /// parent order payment status in a single transaction.
  ///
  /// Returns `null` when the merchant order id does not map to a payment.
  Future<Map<String, dynamic>?> syncStatusByMerchantOrderId({
    required String merchantOrderId,
    required String status,
    String? phonepeOrderId,
    String? phonepeTransactionId,
    String? phonepeState,
    String? phonepePaymentMode,
    Map<String, dynamic>? phonepeRawResponse,
  }) {
    return _pool.runTx((tx) async {
      final targetResult = await tx.execute(
        Sql.named('''
          SELECT p.id,
                 p.order_id
          FROM payments p
          WHERE p.merchant_order_id = @merchantOrderId
          LIMIT 1
        '''),
        parameters: {
          'merchantOrderId': merchantOrderId,
        },
      );

      if (targetResult.isEmpty) {
        return null;
      }

      final targetMap = targetResult.first.toColumnMap();
      final paymentId = targetMap['id'] as String;
      final orderId = targetMap['order_id'] as String;

      final paidAt = status == 'paid' ? DateTime.now().toUtc() : null;
      final failedAt = status == 'failed' ? DateTime.now().toUtc() : null;
      final refundedAt = status == 'refunded' ? DateTime.now().toUtc() : null;

      final updatePaymentResult = await tx.execute(
        Sql.named('''
          UPDATE payments
          SET status = @status,
              phonepe_order_id = COALESCE(@phonepeOrderId, phonepe_order_id),
              phonepe_transaction_id = COALESCE(
                @phonepeTransactionId,
                phonepe_transaction_id
              ),
              phonepe_state = COALESCE(@phonepeState, phonepe_state),
              phonepe_payment_mode = COALESCE(
                @phonepePaymentMode,
                phonepe_payment_mode
              ),
              phonepe_raw_response = COALESCE(
                @phonepeRawResponse,
                phonepe_raw_response
              ),
              paid_at = COALESCE(@paidAt, paid_at),
              failed_at = COALESCE(@failedAt, failed_at),
              refunded_at = COALESCE(@refundedAt, refunded_at)
          WHERE id = @paymentId
          RETURNING id,
                    order_id,
                    store_id,
                    amount,
                    status,
                    merchant_order_id,
                    phonepe_order_id,
                    phonepe_transaction_id,
                    phonepe_state,
                    phonepe_payment_mode,
                    initiated_at,
                    paid_at,
                    failed_at,
                    refunded_at
        '''),
        parameters: {
          'status': status,
          'phonepeOrderId': phonepeOrderId,
          'phonepeTransactionId': phonepeTransactionId,
          'phonepeState': phonepeState,
          'phonepePaymentMode': phonepePaymentMode,
          'phonepeRawResponse': phonepeRawResponse,
          'paidAt': paidAt,
          'failedAt': failedAt,
          'refundedAt': refundedAt,
          'paymentId': paymentId,
        },
      );

      await tx.execute(
        Sql.named('''
          UPDATE orders
          SET payment_status = @status,
              updated_at = NOW()
          WHERE id = @orderId
        '''),
        parameters: {
          'orderId': orderId,
          'status': status,
        },
      );

      final map = updatePaymentResult.first.toColumnMap();
      return {
        'id': map['id'] as String,
        'orderId': map['order_id'] as String,
        'storeId': map['store_id'] as String,
        'amount': map['amount'] as num,
        'status': map['status'] as String,
        'merchantOrderId': map['merchant_order_id'] as String,
        'phonepeOrderId': map['phonepe_order_id'] as String?,
        'phonepeTransactionId': map['phonepe_transaction_id'] as String?,
        'phonepeState': map['phonepe_state'] as String?,
        'phonepePaymentMode': map['phonepe_payment_mode'] as String?,
        'initiatedAt': (map['initiated_at'] as DateTime).toIso8601String(),
        'paidAt': (map['paid_at'] as DateTime?)?.toIso8601String(),
        'failedAt': (map['failed_at'] as DateTime?)?.toIso8601String(),
        'refundedAt': (map['refunded_at'] as DateTime?)?.toIso8601String(),
      };
    });
  }

  /// Syncs a payment status for a cashier-scoped order and propagates it to
  /// the parent order's payment status.
  ///
  /// Returns a map with:
  /// - `orderExists`: `false` if the scoped order does not exist.
  /// - `payment`: updated payment payload or `null` when no payment is found.
  Future<Map<String, dynamic>> syncStatusForCashierOrder({
    required String tenantId,
    required String storeId,
    required String orderId,
    required String status,
    String? merchantOrderId,
    String? phonepeOrderId,
    String? phonepeTransactionId,
    String? phonepeState,
    String? phonepePaymentMode,
    Map<String, dynamic>? phonepeRawResponse,
  }) {
    return _pool.runTx((tx) async {
      final orderScopeResult = await tx.execute(
        Sql.named('''
          SELECT 1
          FROM orders o
          INNER JOIN stores s ON s.id = o.store_id
          WHERE o.id = @orderId
            AND o.store_id = @storeId
            AND s.tenant_id = @tenantId
          LIMIT 1
        '''),
        parameters: {
          'orderId': orderId,
          'storeId': storeId,
          'tenantId': tenantId,
        },
      );

      if (orderScopeResult.isEmpty) {
        return {
          'orderExists': false,
          'payment': null,
        };
      }

      final paymentTargetResult = await tx.execute(
        Sql.named('''
          SELECT p.id
          FROM payments p
          WHERE p.order_id = @orderId
            AND (@merchantOrderId IS NULL OR p.merchant_order_id = @merchantOrderId)
          ORDER BY p.initiated_at DESC, p.id DESC
          LIMIT 1
        '''),
        parameters: {
          'orderId': orderId,
          'merchantOrderId': merchantOrderId,
        },
      );

      if (paymentTargetResult.isEmpty) {
        return {
          'orderExists': true,
          'payment': null,
        };
      }

      final paymentId = paymentTargetResult.first.toColumnMap()['id'] as String;

      final paidAt = status == 'paid' ? DateTime.now().toUtc() : null;
      final failedAt = status == 'failed' ? DateTime.now().toUtc() : null;
      final refundedAt = status == 'refunded' ? DateTime.now().toUtc() : null;

      final updatePaymentResult = await tx.execute(
        Sql.named('''
          UPDATE payments
          SET status = @status,
              phonepe_order_id = COALESCE(@phonepeOrderId, phonepe_order_id),
              phonepe_transaction_id = COALESCE(
                @phonepeTransactionId,
                phonepe_transaction_id
              ),
              phonepe_state = COALESCE(@phonepeState, phonepe_state),
              phonepe_payment_mode = COALESCE(
                @phonepePaymentMode,
                phonepe_payment_mode
              ),
              phonepe_raw_response = COALESCE(
                @phonepeRawResponse,
                phonepe_raw_response
              ),
              paid_at = COALESCE(@paidAt, paid_at),
              failed_at = COALESCE(@failedAt, failed_at),
              refunded_at = COALESCE(@refundedAt, refunded_at)
          WHERE id = @paymentId
          RETURNING id,
                    order_id,
                    store_id,
                    amount,
                    status,
                    merchant_order_id,
                    phonepe_order_id,
                    phonepe_transaction_id,
                    phonepe_state,
                    phonepe_payment_mode,
                    initiated_at,
                    paid_at,
                    failed_at,
                    refunded_at
        '''),
        parameters: {
          'status': status,
          'phonepeOrderId': phonepeOrderId,
          'phonepeTransactionId': phonepeTransactionId,
          'phonepeState': phonepeState,
          'phonepePaymentMode': phonepePaymentMode,
          'phonepeRawResponse': phonepeRawResponse,
          'paidAt': paidAt,
          'failedAt': failedAt,
          'refundedAt': refundedAt,
          'paymentId': paymentId,
        },
      );

      await tx.execute(
        Sql.named('''
          UPDATE orders
          SET payment_status = @status,
              updated_at = NOW()
          WHERE id = @orderId
        '''),
        parameters: {
          'orderId': orderId,
          'status': status,
        },
      );

      final map = updatePaymentResult.first.toColumnMap();
      return {
        'orderExists': true,
        'payment': {
          'id': map['id'] as String,
          'orderId': map['order_id'] as String,
          'storeId': map['store_id'] as String,
          'amount': map['amount'] as num,
          'status': map['status'] as String,
          'merchantOrderId': map['merchant_order_id'] as String,
          'phonepeOrderId': map['phonepe_order_id'] as String?,
          'phonepeTransactionId': map['phonepe_transaction_id'] as String?,
          'phonepeState': map['phonepe_state'] as String?,
          'phonepePaymentMode': map['phonepe_payment_mode'] as String?,
          'initiatedAt': (map['initiated_at'] as DateTime).toIso8601String(),
          'paidAt': (map['paid_at'] as DateTime?)?.toIso8601String(),
          'failedAt': (map['failed_at'] as DateTime?)?.toIso8601String(),
          'refundedAt': (map['refunded_at'] as DateTime?)?.toIso8601String(),
        },
      };
    });
  }

  /// Fetches a payment status snapshot for a cashier-scoped order.
  ///
  /// When [merchantOrderId] is provided, it fetches that specific payment;
  /// otherwise it returns the latest payment for the order.
  Future<Map<String, dynamic>> fetchStatusForCashierOrder({
    required String tenantId,
    required String storeId,
    required String orderId,
    String? merchantOrderId,
  }) async {
    final orderScopeResult = await _pool.execute(
      Sql.named('''
        SELECT 1
        FROM orders o
        INNER JOIN stores s ON s.id = o.store_id
        WHERE o.id = @orderId
          AND o.store_id = @storeId
          AND s.tenant_id = @tenantId
        LIMIT 1
      '''),
      parameters: {
        'orderId': orderId,
        'storeId': storeId,
        'tenantId': tenantId,
      },
    );

    if (orderScopeResult.isEmpty) {
      return {
        'orderExists': false,
        'payment': null,
      };
    }

    final paymentResult = await _pool.execute(
      Sql.named('''
        SELECT p.id,
               p.order_id,
               p.store_id,
               p.amount,
               p.status,
               p.merchant_order_id,
               p.phonepe_order_id,
               p.phonepe_transaction_id,
               p.phonepe_state,
               p.phonepe_payment_mode,
               p.initiated_at,
               p.paid_at,
               p.failed_at,
               p.refunded_at
        FROM payments p
        WHERE p.order_id = @orderId
          AND (@merchantOrderId IS NULL OR p.merchant_order_id = @merchantOrderId)
        ORDER BY p.initiated_at DESC, p.id DESC
        LIMIT 1
      '''),
      parameters: {
        'orderId': orderId,
        'merchantOrderId': merchantOrderId,
      },
    );

    if (paymentResult.isEmpty) {
      return {
        'orderExists': true,
        'payment': null,
      };
    }

    final map = paymentResult.first.toColumnMap();
    return {
      'orderExists': true,
      'payment': {
        'id': map['id'] as String,
        'orderId': map['order_id'] as String,
        'storeId': map['store_id'] as String,
        'amount': map['amount'] as num,
        'status': map['status'] as String,
        'merchantOrderId': map['merchant_order_id'] as String,
        'phonepeOrderId': map['phonepe_order_id'] as String?,
        'phonepeTransactionId': map['phonepe_transaction_id'] as String?,
        'phonepeState': map['phonepe_state'] as String?,
        'phonepePaymentMode': map['phonepe_payment_mode'] as String?,
        'initiatedAt': (map['initiated_at'] as DateTime).toIso8601String(),
        'paidAt': (map['paid_at'] as DateTime?)?.toIso8601String(),
        'failedAt': (map['failed_at'] as DateTime?)?.toIso8601String(),
        'refundedAt': (map['refunded_at'] as DateTime?)?.toIso8601String(),
      },
    };
  }

  /// Initiates a payment for a cashier-scoped order.
  ///
  /// Returns `null` when order is not found for the provided scope.
  Future<Map<String, dynamic>?> initiateForCashierOrder({
    required String tenantId,
    required String storeId,
    required String orderId,
    required String paymentMethod,
  }) {
    return _pool.runTx((tx) async {
      final orderResult = await tx.execute(
        Sql.named('''
          SELECT o.id,
                 o.total,
                 o.payment_status
          FROM orders o
          INNER JOIN stores s ON s.id = o.store_id
          WHERE o.id = @orderId
            AND o.store_id = @storeId
            AND s.tenant_id = @tenantId
          LIMIT 1
        '''),
        parameters: {
          'orderId': orderId,
          'storeId': storeId,
          'tenantId': tenantId,
        },
      );

      if (orderResult.isEmpty) {
        return null;
      }

      final orderMap = orderResult.first.toColumnMap();
      final orderPaymentStatus = orderMap['payment_status'] as String;
      if (orderPaymentStatus != 'pending') {
        throw const OrderPaymentNotPendingException();
      }

      final existingPendingPayment = await tx.execute(
        Sql.named('''
          SELECT id
          FROM payments
          WHERE order_id = @orderId
            AND status = 'pending'
          LIMIT 1
        '''),
        parameters: {'orderId': orderId},
      );

      if (existingPendingPayment.isNotEmpty) {
        throw const PaymentAlreadyInitiatedException();
      }

      final merchantOrderId = _buildMerchantOrderId(orderId);

      final paymentInsertResult = await tx.execute(
        Sql.named('''
          INSERT INTO payments (
            order_id,
            store_id,
            amount,
            status,
            merchant_order_id
          )
          VALUES (
            @orderId,
            @storeId,
            @amount,
            'pending',
            @merchantOrderId
          )
          RETURNING id,
                    order_id,
                    store_id,
                    amount,
                    status,
                    merchant_order_id,
                    initiated_at
        '''),
        parameters: {
          'orderId': orderId,
          'storeId': storeId,
          'amount': orderMap['total'] as num,
          'merchantOrderId': merchantOrderId,
        },
      );

      await tx.execute(
        Sql.named('''
          UPDATE orders
          SET payment_method = @paymentMethod,
              updated_at = NOW()
          WHERE id = @orderId
        '''),
        parameters: {
          'orderId': orderId,
          'paymentMethod': paymentMethod,
        },
      );

      final paymentMap = paymentInsertResult.first.toColumnMap();
      return {
        'id': paymentMap['id'] as String,
        'orderId': paymentMap['order_id'] as String,
        'storeId': paymentMap['store_id'] as String,
        'amount': paymentMap['amount'] as num,
        'status': paymentMap['status'] as String,
        'merchantOrderId': paymentMap['merchant_order_id'] as String,
        'paymentMethod': paymentMethod,
        'initiatedAt': (paymentMap['initiated_at'] as DateTime)
            .toIso8601String(),
      };
    });
  }

  String _buildMerchantOrderId(String orderId) {
    final timestamp = DateTime.now().toUtc().millisecondsSinceEpoch;
    final suffix = orderId.replaceAll('-', '').substring(0, 8);
    return 'MORD-$timestamp-$suffix';
  }
}
