import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pos_server/enums/auth_role.dart';
import 'package:pos_server/models/token_payload.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

import '../../../../routes/cashier/orders/[id].dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

class _MockPool extends Mock implements Pool<String> {}

class _MockResult extends Mock implements Result {}

class _MockResultRow extends Mock implements ResultRow {}

void main() {
  group('POST /cashier/orders/:id', () {
    test('responds with a 405 when method is not allowed', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.post(
          Uri.parse('http://127.0.0.1/cashier/orders/order-id'),
        ),
      );

      final response = await route.onRequest(context, 'order-id');

      expect(response.statusCode, HttpStatus.methodNotAllowed);
      final body = await response.json() as Map<String, dynamic>;
      final code = (body['error'] as Map<String, dynamic>)['code'] as String;
      expect(code, 'METHOD_NOT_ALLOWED');
    });
  });

  group('GET /cashier/orders/:id', () {
    test('returns 400 INVALID_UUID for malformed order id', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.get(
          Uri.parse('http://127.0.0.1/cashier/orders/not-a-uuid'),
        ),
      );

      final response = await route.onRequest(context, 'not-a-uuid');

      expect(response.statusCode, HttpStatus.badRequest);
      final body = await response.json() as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'INVALID_UUID');
    });

    test(
      'returns 401 UNAUTHORIZED when storeId is missing in token',
      () async {
        final context = _MockRequestContext();
        when(() => context.request).thenReturn(
          Request.get(
            Uri.parse(
              'http://127.0.0.1/cashier/orders/550e8400-e29b-41d4-a716-446655440000',
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
      },
    );

    test('returns 500 ORDER_FETCH_FAILED on repository exception', () async {
      final context = _MockRequestContext();
      final pool = _MockPool();

      when(() => context.request).thenReturn(
        Request.get(
          Uri.parse(
            'http://127.0.0.1/cashier/orders/550e8400-e29b-41d4-a716-446655440000',
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
      expect(error['code'], 'ORDER_FETCH_FAILED');
    });

    test('returns 404 ORDER_NOT_FOUND when order does not exist', () async {
      final context = _MockRequestContext();
      final pool = _MockPool();
      final result = _MockResult();

      when(() => context.request).thenReturn(
        Request.get(
          Uri.parse(
            'http://127.0.0.1/cashier/orders/550e8400-e29b-41d4-a716-446655440000',
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
      when(() => result.isEmpty).thenReturn(true);
      when(
        () => pool.execute(any(), parameters: any(named: 'parameters')),
      ).thenAnswer((_) async => result);

      final response = await route.onRequest(
        context,
        '550e8400-e29b-41d4-a716-446655440000',
      );

      expect(response.statusCode, HttpStatus.notFound);
      final body = await response.json() as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'ORDER_NOT_FOUND');
    });

    test('returns 200 with order details on successful fetch', () async {
      final context = _MockRequestContext();
      final pool = _MockPool();
      final orderRow = _MockResultRow();
      final itemRow = _MockResultRow();
      final orderResult = Result(
        rows: [orderRow],
        affectedRows: 1,
        schema: ResultSchema([]),
      );
      final itemResult = Result(
        rows: [itemRow],
        affectedRows: 1,
        schema: ResultSchema([]),
      );

      when(() => context.request).thenReturn(
        Request.get(
          Uri.parse(
            'http://127.0.0.1/cashier/orders/550e8400-e29b-41d4-a716-446655440000',
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
          return orderResult;
        }
        return itemResult;
      });

      when(orderRow.toColumnMap).thenReturn({
        'id': '550e8400-e29b-41d4-a716-446655440000',
        'store_id': '550e8400-e29b-41d4-a716-446655440222',
        'customer_id': null,
        'cashier_id': 'cashier-id',
        'order_number': 'ORD-20260406-0001',
        'source': 'walk_in',
        'status': 'pending',
        'subtotal': 158,
        'gst_amount': 7.9,
        'discount_amount': 0,
        'total': 165.9,
        'payment_method': null,
        'payment_status': 'pending',
        'notes': 'Walk-in order',
        'confirmed_at': null,
        'ready_at': null,
        'completed_at': null,
        'cancelled_at': null,
        'created_at': DateTime.parse('2026-04-06T10:30:00Z'),
        'updated_at': DateTime.parse('2026-04-06T10:35:00Z'),
      });
      when(itemRow.toColumnMap).thenReturn({
        'id': '660e8400-e29b-41d4-a716-446655440001',
        'order_id': '550e8400-e29b-41d4-a716-446655440000',
        'menu_item_id': '550e8400-e29b-41d4-a716-446655440010',
        'item_name': 'Veg Burger',
        'counter_name': 'Kitchen',
        'cost_price': 0,
        'unit_price': 79,
        'gst_percent': 5,
        'quantity': 2,
        'line_total': 158,
        'gst_amount': 7.9,
        'created_at': DateTime.parse('2026-04-06T10:31:00Z'),
      });

      final response = await route.onRequest(
        context,
        '550e8400-e29b-41d4-a716-446655440000',
      );

      expect(response.statusCode, HttpStatus.ok);
      final body = await response.json() as Map<String, dynamic>;
      expect(body['success'], isTrue);
      expect(body['message'], 'Order fetched successfully.');
      final order =
          (body['data'] as Map<String, dynamic>)['order']
              as Map<String, dynamic>;
      expect(order['orderNumber'], 'ORD-20260406-0001');
      expect(order['status'], 'pending');
      expect(order['total'], 165.9);
      final items = order['items'] as List;
      expect(items, hasLength(1));
      final item = items.first as Map<String, dynamic>;
      expect(item['itemName'], 'Veg Burger');
      expect(item['quantity'], 2);
    });
  });

  group('PATCH /cashier/orders/:id', () {
    test('returns 400 INVALID_UUID for malformed order id', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.patch(
          Uri.parse('http://127.0.0.1/cashier/orders/not-a-uuid'),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: '{"status":"confirmed"}',
        ),
      );

      final response = await route.onRequest(context, 'not-a-uuid');

      expect(response.statusCode, HttpStatus.badRequest);
      final body = await response.json() as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'INVALID_UUID');
    });

    test(
      'returns 401 UNAUTHORIZED when storeId is missing in token',
      () async {
        final context = _MockRequestContext();
        when(() => context.request).thenReturn(
          Request.patch(
            Uri.parse(
              'http://127.0.0.1/cashier/orders/550e8400-e29b-41d4-a716-446655440000',
            ),
            headers: {HttpHeaders.contentTypeHeader: 'application/json'},
            body: '{"status":"confirmed"}',
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
      },
    );

    test('returns 400 INVALID_JSON for malformed request body', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.patch(
          Uri.parse(
            'http://127.0.0.1/cashier/orders/550e8400-e29b-41d4-a716-446655440000',
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
            'http://127.0.0.1/cashier/orders/550e8400-e29b-41d4-a716-446655440000',
          ),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: '{"status":"pending"}',
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
      'returns 500 ORDER_STATUS_UPDATE_FAILED on repository exception',
      () async {
        final context = _MockRequestContext();
        final pool = _MockPool();

        when(() => context.request).thenReturn(
          Request.patch(
            Uri.parse(
              'http://127.0.0.1/cashier/orders/550e8400-e29b-41d4-a716-446655440000',
            ),
            headers: {HttpHeaders.contentTypeHeader: 'application/json'},
            body: '{"status":"confirmed"}',
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
        expect(error['code'], 'ORDER_STATUS_UPDATE_FAILED');
      },
    );

    test('returns 404 ORDER_NOT_FOUND when order does not exist', () async {
      final context = _MockRequestContext();
      final pool = _MockPool();
      final result = _MockResult();

      when(() => context.request).thenReturn(
        Request.patch(
          Uri.parse(
            'http://127.0.0.1/cashier/orders/550e8400-e29b-41d4-a716-446655440000',
          ),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: '{"status":"confirmed"}',
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
      when(() => result.isEmpty).thenReturn(true);
      when(
        () => pool.execute(any(), parameters: any(named: 'parameters')),
      ).thenAnswer((_) async => result);

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
      'returns 409 INVALID_STATUS_TRANSITION for disallowed transition',
      () async {
        final context = _MockRequestContext();
        final pool = _MockPool();
        final currentStateResult = _MockResult();
        final row = _MockResultRow();

        when(() => context.request).thenReturn(
          Request.patch(
            Uri.parse(
              'http://127.0.0.1/cashier/orders/550e8400-e29b-41d4-a716-446655440000',
            ),
            headers: {HttpHeaders.contentTypeHeader: 'application/json'},
            body: '{"status":"ready"}',
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
        when(() => currentStateResult.isEmpty).thenReturn(false);
        when(() => currentStateResult.first).thenReturn(row);
        when(row.toColumnMap).thenReturn({'status': 'completed'});
        when(
          () => pool.execute(any(), parameters: any(named: 'parameters')),
        ).thenAnswer((_) async => currentStateResult);

        final response = await route.onRequest(
          context,
          '550e8400-e29b-41d4-a716-446655440000',
        );

        expect(response.statusCode, HttpStatus.conflict);
        final body = await response.json() as Map<String, dynamic>;
        final error = body['error'] as Map<String, dynamic>;
        expect(error['code'], 'INVALID_STATUS_TRANSITION');
      },
    );

    test('returns 200 with updated order on successful transition', () async {
      final context = _MockRequestContext();
      final pool = _MockPool();
      final currentStateRow = _MockResultRow();
      final updatedOrderRow = _MockResultRow();
      final orderItemRow = _MockResultRow();

      final currentStateResult = Result(
        rows: [currentStateRow],
        affectedRows: 1,
        schema: ResultSchema([]),
      );
      final updateResult = Result(
        rows: [_MockResultRow()],
        affectedRows: 1,
        schema: ResultSchema([]),
      );
      final orderResult = Result(
        rows: [updatedOrderRow],
        affectedRows: 1,
        schema: ResultSchema([]),
      );
      final itemsResult = Result(
        rows: [orderItemRow],
        affectedRows: 1,
        schema: ResultSchema([]),
      );

      when(() => context.request).thenReturn(
        Request.patch(
          Uri.parse(
            'http://127.0.0.1/cashier/orders/550e8400-e29b-41d4-a716-446655440000',
          ),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: '{"status":"confirmed"}',
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
          return currentStateResult;
        }
        if (executeCalls == 2) {
          return updateResult;
        }
        if (executeCalls == 3) {
          return orderResult;
        }
        return itemsResult;
      });

      when(currentStateRow.toColumnMap).thenReturn({'status': 'pending'});
      when(updatedOrderRow.toColumnMap).thenReturn({
        'id': '550e8400-e29b-41d4-a716-446655440000',
        'store_id': '550e8400-e29b-41d4-a716-446655440222',
        'customer_id': null,
        'cashier_id': 'cashier-id',
        'order_number': 'ORD-20260406-0001',
        'source': 'walk_in',
        'status': 'confirmed',
        'subtotal': 158,
        'gst_amount': 7.9,
        'discount_amount': 0,
        'total': 165.9,
        'payment_method': null,
        'payment_status': 'pending',
        'notes': 'Walk-in order',
        'confirmed_at': DateTime.parse('2026-04-06T11:00:00Z'),
        'ready_at': null,
        'completed_at': null,
        'cancelled_at': null,
        'created_at': DateTime.parse('2026-04-06T10:30:00Z'),
        'updated_at': DateTime.parse('2026-04-06T11:00:00Z'),
      });
      when(orderItemRow.toColumnMap).thenReturn({
        'id': '660e8400-e29b-41d4-a716-446655440001',
        'order_id': '550e8400-e29b-41d4-a716-446655440000',
        'menu_item_id': '550e8400-e29b-41d4-a716-446655440010',
        'item_name': 'Veg Burger',
        'counter_name': 'Kitchen',
        'cost_price': 0,
        'unit_price': 79,
        'gst_percent': 5,
        'quantity': 2,
        'line_total': 158,
        'gst_amount': 7.9,
        'created_at': DateTime.parse('2026-04-06T10:31:00Z'),
      });

      final response = await route.onRequest(
        context,
        '550e8400-e29b-41d4-a716-446655440000',
      );

      expect(response.statusCode, HttpStatus.ok);
      final body = await response.json() as Map<String, dynamic>;
      expect(body['success'], isTrue);
      expect(body['message'], 'Order status updated successfully.');
      final order =
          (body['data'] as Map<String, dynamic>)['order']
              as Map<String, dynamic>;
      expect(order['status'], 'confirmed');
      expect(order['confirmedAt'], isNotNull);
      final items = order['items'] as List;
      expect(items, hasLength(1));
    });
  });
}
