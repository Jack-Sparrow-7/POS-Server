import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pos_server/enums/auth_role.dart';
import 'package:pos_server/models/token_payload.dart';
import 'package:pos_server/repositories/payment_repository.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

import '../../../../../../routes/cashier/orders/[id]/payments/index.dart'
    as route;

class _MockRequestContext extends Mock implements RequestContext {}

class _MockPool extends Mock implements Pool<String> {}

class _MockResultRow extends Mock implements ResultRow {}

void main() {
  group('GET /cashier/orders/:id/payments', () {
    test('responds with a 405 when method is not allowed', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.put(
          Uri.parse('http://127.0.0.1/cashier/orders/order-id/payments'),
        ),
      );

      final response = await route.onRequest(context, 'order-id');

      expect(response.statusCode, HttpStatus.methodNotAllowed);
      final body = await response.json() as Map<String, dynamic>;
      final code = (body['error'] as Map<String, dynamic>)['code'] as String;
      expect(code, 'METHOD_NOT_ALLOWED');
    });

    test('returns 400 INVALID_UUID for malformed order id', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.get(
          Uri.parse('http://127.0.0.1/cashier/orders/not-a-uuid/payments'),
        ),
      );

      final response = await route.onRequest(context, 'not-a-uuid');

      expect(response.statusCode, HttpStatus.badRequest);
      final body = await response.json() as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'INVALID_UUID');
    });

    test('returns 401 UNAUTHORIZED when storeId is missing in token', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.get(
          Uri.parse(
            'http://127.0.0.1/cashier/orders/550e8400-e29b-41d4-a716-446655440000/payments',
          ),
        ),
      );
      when(() => context.read<TokenPayload>()).thenReturn(
        TokenPayload(
          id: 'cashier-id',
          role: AuthRole.cashier,
          tenantId: '550e8400-e29b-41d4-a716-446655440111',
        ),
      );

      final response = await route.onRequest(
        context,
        '550e8400-e29b-41d4-a716-446655440000',
      );

      expect(response.statusCode, HttpStatus.unauthorized);
      final body = await response.json() as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'UNAUTHORIZED');
    });

    test('returns 400 INVALID_INPUT for empty merchantOrderId', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.get(
          Uri.parse(
            'http://127.0.0.1/cashier/orders/550e8400-e29b-41d4-a716-446655440000/payments?merchantOrderId=%20%20',
          ),
        ),
      );
      when(() => context.read<TokenPayload>()).thenReturn(
        TokenPayload(
          id: 'cashier-id',
          role: AuthRole.cashier,
          tenantId: '550e8400-e29b-41d4-a716-446655440111',
          storeId: '550e8400-e29b-41d4-a716-446655440222',
        ),
      );

      final response = await route.onRequest(
        context,
        '550e8400-e29b-41d4-a716-446655440000',
      );

      expect(response.statusCode, HttpStatus.badRequest);
      final body = await response.json() as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'INVALID_INPUT');
    });

    test('returns 500 PAYMENT_FETCH_FAILED on repository exception', () async {
      final context = _MockRequestContext();
      final pool = _MockPool();
      when(() => context.request).thenReturn(
        Request.get(
          Uri.parse(
            'http://127.0.0.1/cashier/orders/550e8400-e29b-41d4-a716-446655440000/payments',
          ),
        ),
      );
      when(() => context.read<TokenPayload>()).thenReturn(
        TokenPayload(
          id: 'cashier-id',
          role: AuthRole.cashier,
          tenantId: '550e8400-e29b-41d4-a716-446655440111',
          storeId: '550e8400-e29b-41d4-a716-446655440222',
        ),
      );
      when(() => context.read<Pool<String>>()).thenReturn(pool);
      when(
        () => pool.execute(any(), parameters: any(named: 'parameters')),
      ).thenThrow(Exception('temporary db failure'));

      final response = await route.onRequest(
        context,
        '550e8400-e29b-41d4-a716-446655440000',
      );

      expect(response.statusCode, HttpStatus.internalServerError);
      final body = await response.json() as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'PAYMENT_FETCH_FAILED');
    });

    test('returns 404 ORDER_NOT_FOUND when order does not exist', () async {
      final context = _MockRequestContext();
      final pool = _MockPool();
      final orderScopeResult = Result(
        rows: const [],
        affectedRows: 0,
        schema: ResultSchema([]),
      );
      when(() => context.request).thenReturn(
        Request.get(
          Uri.parse(
            'http://127.0.0.1/cashier/orders/550e8400-e29b-41d4-a716-446655440000/payments',
          ),
        ),
      );
      when(() => context.read<TokenPayload>()).thenReturn(
        TokenPayload(
          id: 'cashier-id',
          role: AuthRole.cashier,
          tenantId: '550e8400-e29b-41d4-a716-446655440111',
          storeId: '550e8400-e29b-41d4-a716-446655440222',
        ),
      );
      when(() => context.read<Pool<String>>()).thenReturn(pool);
      when(
        () => pool.execute(any(), parameters: any(named: 'parameters')),
      ).thenAnswer((_) async => orderScopeResult);

      final response = await route.onRequest(
        context,
        '550e8400-e29b-41d4-a716-446655440000',
      );

      expect(response.statusCode, HttpStatus.notFound);
      final body = await response.json() as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'ORDER_NOT_FOUND');
    });

    test('returns 404 PAYMENT_NOT_FOUND when payment does not exist', () async {
      final context = _MockRequestContext();
      final pool = _MockPool();
      final orderScopeRow = _MockResultRow();
      final orderScopeResult = Result(
        rows: [orderScopeRow],
        affectedRows: 1,
        schema: ResultSchema([]),
      );
      final paymentResult = Result(
        rows: const [],
        affectedRows: 0,
        schema: ResultSchema([]),
      );
      when(() => context.request).thenReturn(
        Request.get(
          Uri.parse(
            'http://127.0.0.1/cashier/orders/550e8400-e29b-41d4-a716-446655440000/payments',
          ),
        ),
      );
      when(() => context.read<TokenPayload>()).thenReturn(
        TokenPayload(
          id: 'cashier-id',
          role: AuthRole.cashier,
          tenantId: '550e8400-e29b-41d4-a716-446655440111',
          storeId: '550e8400-e29b-41d4-a716-446655440222',
        ),
      );
      when(() => context.read<Pool<String>>()).thenReturn(pool);
      var executeCalls = 0;
      when(
        () => pool.execute(any(), parameters: any(named: 'parameters')),
      ).thenAnswer((_) async {
        executeCalls += 1;
        if (executeCalls == 1) {
          return orderScopeResult;
        }
        return paymentResult;
      });

      final response = await route.onRequest(
        context,
        '550e8400-e29b-41d4-a716-446655440000',
      );

      expect(response.statusCode, HttpStatus.notFound);
      final body = await response.json() as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'PAYMENT_NOT_FOUND');
    });

    test('returns 200 with latest payment status', () async {
      final context = _MockRequestContext();
      final pool = _MockPool();
      final orderScopeRow = _MockResultRow();
      final paymentRow = _MockResultRow();
      final orderScopeResult = Result(
        rows: [orderScopeRow],
        affectedRows: 1,
        schema: ResultSchema([]),
      );
      final paymentResult = Result(
        rows: [paymentRow],
        affectedRows: 1,
        schema: ResultSchema([]),
      );
      when(() => context.request).thenReturn(
        Request.get(
          Uri.parse(
            'http://127.0.0.1/cashier/orders/550e8400-e29b-41d4-a716-446655440000/payments?merchantOrderId=MORD-1712400000000-550e8400',
          ),
        ),
      );
      when(() => context.read<TokenPayload>()).thenReturn(
        TokenPayload(
          id: 'cashier-id',
          role: AuthRole.cashier,
          tenantId: '550e8400-e29b-41d4-a716-446655440111',
          storeId: '550e8400-e29b-41d4-a716-446655440222',
        ),
      );
      when(() => context.read<Pool<String>>()).thenReturn(pool);
      var executeCalls = 0;
      when(
        () => pool.execute(any(), parameters: any(named: 'parameters')),
      ).thenAnswer((_) async {
        executeCalls += 1;
        if (executeCalls == 1) {
          return orderScopeResult;
        }
        return paymentResult;
      });

      when(paymentRow.toColumnMap).thenReturn({
        'id': '770e8400-e29b-41d4-a716-446655440001',
        'order_id': '550e8400-e29b-41d4-a716-446655440000',
        'store_id': '550e8400-e29b-41d4-a716-446655440222',
        'amount': 165.9,
        'status': 'paid',
        'merchant_order_id': 'MORD-1712400000000-550e8400',
        'phonepe_order_id': 'PPE-123',
        'phonepe_transaction_id': 'TXN-123',
        'phonepe_state': 'COMPLETED',
        'phonepe_payment_mode': 'UPI_INTENT',
        'initiated_at': DateTime.parse('2026-04-06T12:00:00Z'),
        'paid_at': DateTime.parse('2026-04-06T12:01:00Z'),
        'failed_at': null,
        'refunded_at': null,
      });

      final response = await route.onRequest(
        context,
        '550e8400-e29b-41d4-a716-446655440000',
      );

      expect(response.statusCode, HttpStatus.ok);
      final body = await response.json() as Map<String, dynamic>;
      expect(body['success'], isTrue);
      expect(body['message'], 'Payment status fetched successfully.');
      final payment =
          (body['data'] as Map<String, dynamic>)['payment']
              as Map<String, dynamic>;
      expect(payment['merchantOrderId'], 'MORD-1712400000000-550e8400');
      expect(payment['status'], 'paid');
      expect(payment['phonepeOrderId'], 'PPE-123');
    });
  });

  group('POST /cashier/orders/:id/payments', () {
    test('returns 400 INVALID_UUID for malformed order id', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.post(
          Uri.parse('http://127.0.0.1/cashier/orders/not-a-uuid/payments'),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: '{"paymentMethod":"cash"}',
        ),
      );

      final response = await route.onRequest(context, 'not-a-uuid');

      expect(response.statusCode, HttpStatus.badRequest);
      final body = await response.json() as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'INVALID_UUID');
    });

    test('returns 401 UNAUTHORIZED when storeId is missing in token', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.post(
          Uri.parse(
            'http://127.0.0.1/cashier/orders/550e8400-e29b-41d4-a716-446655440000/payments',
          ),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: '{"paymentMethod":"cash"}',
        ),
      );
      when(() => context.read<TokenPayload>()).thenReturn(
        TokenPayload(
          id: 'cashier-id',
          role: AuthRole.cashier,
          tenantId: '550e8400-e29b-41d4-a716-446655440111',
        ),
      );

      final response = await route.onRequest(
        context,
        '550e8400-e29b-41d4-a716-446655440000',
      );

      expect(response.statusCode, HttpStatus.unauthorized);
      final body = await response.json() as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'UNAUTHORIZED');
    });

    test('returns 400 INVALID_JSON for malformed request body', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.post(
          Uri.parse(
            'http://127.0.0.1/cashier/orders/550e8400-e29b-41d4-a716-446655440000/payments',
          ),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: '{invalid',
        ),
      );
      when(() => context.read<TokenPayload>()).thenReturn(
        TokenPayload(
          id: 'cashier-id',
          role: AuthRole.cashier,
          tenantId: '550e8400-e29b-41d4-a716-446655440111',
          storeId: '550e8400-e29b-41d4-a716-446655440222',
        ),
      );

      final response = await route.onRequest(
        context,
        '550e8400-e29b-41d4-a716-446655440000',
      );

      expect(response.statusCode, HttpStatus.badRequest);
      final body = await response.json() as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'INVALID_JSON');
    });

    test('returns 400 INVALID_INPUT for invalid paymentMethod', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.post(
          Uri.parse(
            'http://127.0.0.1/cashier/orders/550e8400-e29b-41d4-a716-446655440000/payments',
          ),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: '{"paymentMethod":"upi_online"}',
        ),
      );
      when(() => context.read<TokenPayload>()).thenReturn(
        TokenPayload(
          id: 'cashier-id',
          role: AuthRole.cashier,
          tenantId: '550e8400-e29b-41d4-a716-446655440111',
          storeId: '550e8400-e29b-41d4-a716-446655440222',
        ),
      );

      final response = await route.onRequest(
        context,
        '550e8400-e29b-41d4-a716-446655440000',
      );

      expect(response.statusCode, HttpStatus.badRequest);
      final body = await response.json() as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'INVALID_INPUT');
    });

    test(
      'returns 409 ORDER_PAYMENT_NOT_PENDING for invalid payment state',
      () async {
        final context = _MockRequestContext();
        final pool = _MockPool();
        when(() => context.request).thenReturn(
          Request.post(
            Uri.parse(
              'http://127.0.0.1/cashier/orders/550e8400-e29b-41d4-a716-446655440000/payments',
            ),
            headers: {HttpHeaders.contentTypeHeader: 'application/json'},
            body: '{"paymentMethod":"cash"}',
          ),
        );
        when(() => context.read<TokenPayload>()).thenReturn(
          TokenPayload(
            id: 'cashier-id',
            role: AuthRole.cashier,
            tenantId: '550e8400-e29b-41d4-a716-446655440111',
            storeId: '550e8400-e29b-41d4-a716-446655440222',
          ),
        );
        when(() => context.read<Pool<String>>()).thenReturn(pool);
        when(
          () => pool.runTx<Map<String, dynamic>?>(any()),
        ).thenThrow(const OrderPaymentNotPendingException());

        final response = await route.onRequest(
          context,
          '550e8400-e29b-41d4-a716-446655440000',
        );

        expect(response.statusCode, HttpStatus.conflict);
        final body = await response.json() as Map<String, dynamic>;
        final error = body['error'] as Map<String, dynamic>;
        expect(error['code'], 'ORDER_PAYMENT_NOT_PENDING');
      },
    );

    test(
      'returns 409 PAYMENT_ALREADY_INITIATED for duplicate pending',
      () async {
        final context = _MockRequestContext();
        final pool = _MockPool();
        when(() => context.request).thenReturn(
          Request.post(
            Uri.parse(
              'http://127.0.0.1/cashier/orders/550e8400-e29b-41d4-a716-446655440000/payments',
            ),
            headers: {HttpHeaders.contentTypeHeader: 'application/json'},
            body: '{"paymentMethod":"card"}',
          ),
        );
        when(() => context.read<TokenPayload>()).thenReturn(
          TokenPayload(
            id: 'cashier-id',
            role: AuthRole.cashier,
            tenantId: '550e8400-e29b-41d4-a716-446655440111',
            storeId: '550e8400-e29b-41d4-a716-446655440222',
          ),
        );
        when(() => context.read<Pool<String>>()).thenReturn(pool);
        when(
          () => pool.runTx<Map<String, dynamic>?>(any()),
        ).thenThrow(const PaymentAlreadyInitiatedException());

        final response = await route.onRequest(
          context,
          '550e8400-e29b-41d4-a716-446655440000',
        );

        expect(response.statusCode, HttpStatus.conflict);
        final body = await response.json() as Map<String, dynamic>;
        final error = body['error'] as Map<String, dynamic>;
        expect(error['code'], 'PAYMENT_ALREADY_INITIATED');
      },
    );

    test('returns 404 ORDER_NOT_FOUND when order does not exist', () async {
      final context = _MockRequestContext();
      final pool = _MockPool();
      when(() => context.request).thenReturn(
        Request.post(
          Uri.parse(
            'http://127.0.0.1/cashier/orders/550e8400-e29b-41d4-a716-446655440000/payments',
          ),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: '{"paymentMethod":"cash"}',
        ),
      );
      when(() => context.read<TokenPayload>()).thenReturn(
        TokenPayload(
          id: 'cashier-id',
          role: AuthRole.cashier,
          tenantId: '550e8400-e29b-41d4-a716-446655440111',
          storeId: '550e8400-e29b-41d4-a716-446655440222',
        ),
      );
      when(() => context.read<Pool<String>>()).thenReturn(pool);
      when(
        () => pool.runTx<Map<String, dynamic>?>(any()),
      ).thenAnswer((_) async => null);

      final response = await route.onRequest(
        context,
        '550e8400-e29b-41d4-a716-446655440000',
      );

      expect(response.statusCode, HttpStatus.notFound);
      final body = await response.json() as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'ORDER_NOT_FOUND');
    });

    test(
      'returns 500 PAYMENT_INITIATION_FAILED on repository exception',
      () async {
        final context = _MockRequestContext();
        final pool = _MockPool();
        when(() => context.request).thenReturn(
          Request.post(
            Uri.parse(
              'http://127.0.0.1/cashier/orders/550e8400-e29b-41d4-a716-446655440000/payments',
            ),
            headers: {HttpHeaders.contentTypeHeader: 'application/json'},
            body: '{"paymentMethod":"cash"}',
          ),
        );
        when(() => context.read<TokenPayload>()).thenReturn(
          TokenPayload(
            id: 'cashier-id',
            role: AuthRole.cashier,
            tenantId: '550e8400-e29b-41d4-a716-446655440111',
            storeId: '550e8400-e29b-41d4-a716-446655440222',
          ),
        );
        when(() => context.read<Pool<String>>()).thenReturn(pool);
        when(
          () => pool.runTx<Map<String, dynamic>?>(any()),
        ).thenThrow(Exception('temporary db failure'));

        final response = await route.onRequest(
          context,
          '550e8400-e29b-41d4-a716-446655440000',
        );

        expect(response.statusCode, HttpStatus.internalServerError);
        final body = await response.json() as Map<String, dynamic>;
        final error = body['error'] as Map<String, dynamic>;
        expect(error['code'], 'PAYMENT_INITIATION_FAILED');
      },
    );

    test('returns 201 with payment payload on success', () async {
      final context = _MockRequestContext();
      final pool = _MockPool();
      when(() => context.request).thenReturn(
        Request.post(
          Uri.parse(
            'http://127.0.0.1/cashier/orders/550e8400-e29b-41d4-a716-446655440000/payments',
          ),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: '{"paymentMethod":"cash"}',
        ),
      );
      when(() => context.read<TokenPayload>()).thenReturn(
        TokenPayload(
          id: 'cashier-id',
          role: AuthRole.cashier,
          tenantId: '550e8400-e29b-41d4-a716-446655440111',
          storeId: '550e8400-e29b-41d4-a716-446655440222',
        ),
      );
      when(() => context.read<Pool<String>>()).thenReturn(pool);
      when(
        () => pool.runTx<Map<String, dynamic>?>(any()),
      ).thenAnswer(
        (_) async => {
          'id': '770e8400-e29b-41d4-a716-446655440001',
          'orderId': '550e8400-e29b-41d4-a716-446655440000',
          'storeId': '550e8400-e29b-41d4-a716-446655440222',
          'amount': 165.9,
          'status': 'pending',
          'merchantOrderId': 'MORD-1712400000000-550e8400',
          'paymentMethod': 'cash',
          'initiatedAt': '2026-04-06T12:00:00.000Z',
        },
      );

      final response = await route.onRequest(
        context,
        '550e8400-e29b-41d4-a716-446655440000',
      );

      expect(response.statusCode, HttpStatus.created);
      final body = await response.json() as Map<String, dynamic>;
      expect(body['success'], isTrue);
      expect(body['message'], 'Payment initiated successfully.');
      final payment =
          (body['data'] as Map<String, dynamic>)['payment']
              as Map<String, dynamic>;
      expect(payment['orderId'], '550e8400-e29b-41d4-a716-446655440000');
      expect(payment['status'], 'pending');
      expect(payment['paymentMethod'], 'cash');
    });
  });

  group('PATCH /cashier/orders/:id/payments', () {
    test('returns 400 INVALID_UUID for malformed order id', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.patch(
          Uri.parse('http://127.0.0.1/cashier/orders/not-a-uuid/payments'),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: '{"status":"paid"}',
        ),
      );

      final response = await route.onRequest(context, 'not-a-uuid');

      expect(response.statusCode, HttpStatus.badRequest);
      final body = await response.json() as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'INVALID_UUID');
    });

    test('returns 401 UNAUTHORIZED when storeId is missing in token', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.patch(
          Uri.parse(
            'http://127.0.0.1/cashier/orders/550e8400-e29b-41d4-a716-446655440000/payments',
          ),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: '{"status":"paid"}',
        ),
      );
      when(() => context.read<TokenPayload>()).thenReturn(
        TokenPayload(
          id: 'cashier-id',
          role: AuthRole.cashier,
          tenantId: '550e8400-e29b-41d4-a716-446655440111',
        ),
      );

      final response = await route.onRequest(
        context,
        '550e8400-e29b-41d4-a716-446655440000',
      );

      expect(response.statusCode, HttpStatus.unauthorized);
      final body = await response.json() as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'UNAUTHORIZED');
    });

    test('returns 400 INVALID_JSON for malformed request body', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.patch(
          Uri.parse(
            'http://127.0.0.1/cashier/orders/550e8400-e29b-41d4-a716-446655440000/payments',
          ),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: '{invalid',
        ),
      );
      when(() => context.read<TokenPayload>()).thenReturn(
        TokenPayload(
          id: 'cashier-id',
          role: AuthRole.cashier,
          tenantId: '550e8400-e29b-41d4-a716-446655440111',
          storeId: '550e8400-e29b-41d4-a716-446655440222',
        ),
      );

      final response = await route.onRequest(
        context,
        '550e8400-e29b-41d4-a716-446655440000',
      );

      expect(response.statusCode, HttpStatus.badRequest);
      final body = await response.json() as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'INVALID_JSON');
    });

    test('returns 400 INVALID_INPUT for invalid status payload', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.patch(
          Uri.parse(
            'http://127.0.0.1/cashier/orders/550e8400-e29b-41d4-a716-446655440000/payments',
          ),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: '{"status":"processing"}',
        ),
      );
      when(() => context.read<TokenPayload>()).thenReturn(
        TokenPayload(
          id: 'cashier-id',
          role: AuthRole.cashier,
          tenantId: '550e8400-e29b-41d4-a716-446655440111',
          storeId: '550e8400-e29b-41d4-a716-446655440222',
        ),
      );

      final response = await route.onRequest(
        context,
        '550e8400-e29b-41d4-a716-446655440000',
      );

      expect(response.statusCode, HttpStatus.badRequest);
      final body = await response.json() as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'INVALID_INPUT');
    });

    test('returns 404 ORDER_NOT_FOUND when order does not exist', () async {
      final context = _MockRequestContext();
      final pool = _MockPool();
      when(() => context.request).thenReturn(
        Request.patch(
          Uri.parse(
            'http://127.0.0.1/cashier/orders/550e8400-e29b-41d4-a716-446655440000/payments',
          ),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: '{"status":"paid"}',
        ),
      );
      when(() => context.read<TokenPayload>()).thenReturn(
        TokenPayload(
          id: 'cashier-id',
          role: AuthRole.cashier,
          tenantId: '550e8400-e29b-41d4-a716-446655440111',
          storeId: '550e8400-e29b-41d4-a716-446655440222',
        ),
      );
      when(() => context.read<Pool<String>>()).thenReturn(pool);
      when(
        () => pool.runTx<Map<String, dynamic>>(any()),
      ).thenAnswer(
        (_) async => {
          'orderExists': false,
          'payment': null,
        },
      );

      final response = await route.onRequest(
        context,
        '550e8400-e29b-41d4-a716-446655440000',
      );

      expect(response.statusCode, HttpStatus.notFound);
      final body = await response.json() as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'ORDER_NOT_FOUND');
    });

    test('returns 404 PAYMENT_NOT_FOUND when payment does not exist', () async {
      final context = _MockRequestContext();
      final pool = _MockPool();
      when(() => context.request).thenReturn(
        Request.patch(
          Uri.parse(
            'http://127.0.0.1/cashier/orders/550e8400-e29b-41d4-a716-446655440000/payments',
          ),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: '{"status":"paid"}',
        ),
      );
      when(() => context.read<TokenPayload>()).thenReturn(
        TokenPayload(
          id: 'cashier-id',
          role: AuthRole.cashier,
          tenantId: '550e8400-e29b-41d4-a716-446655440111',
          storeId: '550e8400-e29b-41d4-a716-446655440222',
        ),
      );
      when(() => context.read<Pool<String>>()).thenReturn(pool);
      when(
        () => pool.runTx<Map<String, dynamic>>(any()),
      ).thenAnswer(
        (_) async => {
          'orderExists': true,
          'payment': null,
        },
      );

      final response = await route.onRequest(
        context,
        '550e8400-e29b-41d4-a716-446655440000',
      );

      expect(response.statusCode, HttpStatus.notFound);
      final body = await response.json() as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'PAYMENT_NOT_FOUND');
    });

    test(
      'returns 500 PAYMENT_STATUS_SYNC_FAILED on repository exception',
      () async {
        final context = _MockRequestContext();
        final pool = _MockPool();
        when(() => context.request).thenReturn(
          Request.patch(
            Uri.parse(
              'http://127.0.0.1/cashier/orders/550e8400-e29b-41d4-a716-446655440000/payments',
            ),
            headers: {HttpHeaders.contentTypeHeader: 'application/json'},
            body: '{"status":"paid"}',
          ),
        );
        when(() => context.read<TokenPayload>()).thenReturn(
          TokenPayload(
            id: 'cashier-id',
            role: AuthRole.cashier,
            tenantId: '550e8400-e29b-41d4-a716-446655440111',
            storeId: '550e8400-e29b-41d4-a716-446655440222',
          ),
        );
        when(() => context.read<Pool<String>>()).thenReturn(pool);
        when(
          () => pool.runTx<Map<String, dynamic>>(any()),
        ).thenThrow(Exception('temporary db failure'));

        final response = await route.onRequest(
          context,
          '550e8400-e29b-41d4-a716-446655440000',
        );

        expect(response.statusCode, HttpStatus.internalServerError);
        final body = await response.json() as Map<String, dynamic>;
        final error = body['error'] as Map<String, dynamic>;
        expect(error['code'], 'PAYMENT_STATUS_SYNC_FAILED');
      },
    );

    test('returns 200 with synced payment payload on success', () async {
      final context = _MockRequestContext();
      final pool = _MockPool();
      when(() => context.request).thenReturn(
        Request.patch(
          Uri.parse(
            'http://127.0.0.1/cashier/orders/550e8400-e29b-41d4-a716-446655440000/payments',
          ),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: [
            '{"status":"paid",',
            '"merchantOrderId":"MORD-1712400000000-550e8400"}',
          ].join(),
        ),
      );
      when(() => context.read<TokenPayload>()).thenReturn(
        TokenPayload(
          id: 'cashier-id',
          role: AuthRole.cashier,
          tenantId: '550e8400-e29b-41d4-a716-446655440111',
          storeId: '550e8400-e29b-41d4-a716-446655440222',
        ),
      );
      when(() => context.read<Pool<String>>()).thenReturn(pool);
      when(
        () => pool.runTx<Map<String, dynamic>>(any()),
      ).thenAnswer(
        (_) async => {
          'orderExists': true,
          'payment': {
            'id': '770e8400-e29b-41d4-a716-446655440001',
            'orderId': '550e8400-e29b-41d4-a716-446655440000',
            'storeId': '550e8400-e29b-41d4-a716-446655440222',
            'amount': 165.9,
            'status': 'paid',
            'merchantOrderId': 'MORD-1712400000000-550e8400',
            'phonepeOrderId': 'PPE-123',
            'phonepeTransactionId': 'TXN-123',
            'phonepeState': 'COMPLETED',
            'phonepePaymentMode': 'UPI_INTENT',
            'initiatedAt': '2026-04-06T12:00:00.000Z',
            'paidAt': '2026-04-06T12:01:00.000Z',
            'failedAt': null,
            'refundedAt': null,
          },
        },
      );

      final response = await route.onRequest(
        context,
        '550e8400-e29b-41d4-a716-446655440000',
      );

      expect(response.statusCode, HttpStatus.ok);
      final body = await response.json() as Map<String, dynamic>;
      expect(body['success'], isTrue);
      expect(body['message'], 'Payment status synced successfully.');
      final payment =
          (body['data'] as Map<String, dynamic>)['payment']
              as Map<String, dynamic>;
      expect(payment['status'], 'paid');
      expect(payment['merchantOrderId'], 'MORD-1712400000000-550e8400');
    });
  });
}
