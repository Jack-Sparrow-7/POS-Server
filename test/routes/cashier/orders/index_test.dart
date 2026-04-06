import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pos_server/enums/auth_role.dart';
import 'package:pos_server/models/token_payload.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

import '../../../../routes/cashier/orders/index.dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

class _MockPool extends Mock implements Pool<String> {}

class _MockResultRow extends Mock implements ResultRow {}

void main() {
  group('GET /cashier/orders', () {
    test('responds with a 405 when method is not allowed', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.put(Uri.parse('http://127.0.0.1/cashier/orders')),
      );

      final response = await route.onRequest(context);

      expect(response.statusCode, HttpStatus.methodNotAllowed);
      final body = await response.json() as Map<String, dynamic>;
      final code = (body['error'] as Map<String, dynamic>)['code'] as String;
      expect(code, 'METHOD_NOT_ALLOWED');
    });

    test('returns 403 FORBIDDEN when store scope is missing', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.get(Uri.parse('http://127.0.0.1/cashier/orders')),
      );
      when(() => context.read<TokenPayload>()).thenReturn(
        TokenPayload(
          id: 'cashier-id',
          role: AuthRole.cashier,
          tenantId: '550e8400-e29b-41d4-a716-446655440111',
        ),
      );

      final response = await route.onRequest(context);

      expect(response.statusCode, HttpStatus.forbidden);
      final body = await response.json() as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'FORBIDDEN');
    });

    test('returns 400 INVALID_INPUT for unsupported status filter', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.get(
          Uri.parse('http://127.0.0.1/cashier/orders?status=archived'),
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

      final response = await route.onRequest(context);

      expect(response.statusCode, HttpStatus.badRequest);
      final body = await response.json() as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'INVALID_INPUT');
    });

    test('returns 400 INVALID_INPUT for malformed fromDate', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.get(
          Uri.parse('http://127.0.0.1/cashier/orders?fromDate=not-a-date'),
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

      final response = await route.onRequest(context);

      expect(response.statusCode, HttpStatus.badRequest);
      final body = await response.json() as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'INVALID_INPUT');
    });

    test('returns 400 INVALID_INPUT when fromDate is after toDate', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.get(
          Uri.parse(
            'http://127.0.0.1/cashier/orders?fromDate=2026-04-07&toDate=2026-04-06',
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

      final response = await route.onRequest(context);

      expect(response.statusCode, HttpStatus.badRequest);
      final body = await response.json() as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'INVALID_INPUT');
    });

    test('returns 500 ORDERS_FETCH_FAILED on repository exception', () async {
      final context = _MockRequestContext();
      final pool = _MockPool();
      when(() => context.request).thenReturn(
        Request.get(
          Uri.parse('http://127.0.0.1/cashier/orders?status=pending'),
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

      final response = await route.onRequest(context);

      expect(response.statusCode, HttpStatus.internalServerError);
      final body = await response.json() as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'ORDERS_FETCH_FAILED');
    });

    test('returns 200 with orders list', () async {
      final context = _MockRequestContext();
      final pool = _MockPool();
      final row = _MockResultRow();
      final result = Result(
        rows: [row],
        affectedRows: 1,
        schema: ResultSchema([]),
      );

      when(() => context.request).thenReturn(
        Request.get(
          Uri.parse(
            'http://127.0.0.1/cashier/orders?status=pending&fromDate=2026-04-01&toDate=2026-04-30',
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
      when(row.toColumnMap).thenReturn({
        'id': '550e8400-e29b-41d4-a716-446655440777',
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
        'created_at': DateTime.parse('2026-04-06T10:30:00Z'),
        'updated_at': DateTime.parse('2026-04-06T10:35:00Z'),
      });
      when(
        () => pool.execute(any(), parameters: any(named: 'parameters')),
      ).thenAnswer((_) async => result);

      final response = await route.onRequest(context);

      expect(response.statusCode, HttpStatus.ok);
      final body = await response.json() as Map<String, dynamic>;
      expect(body['success'], isTrue);
      expect(body['message'], 'Orders fetched successfully.');
      final orders = (body['data'] as Map<String, dynamic>)['orders'] as List;
      expect(orders, hasLength(1));
      final order = orders.first as Map<String, dynamic>;
      expect(order['status'], 'pending');
      expect(order['total'], 165.9);
    });
  });

  group('POST /cashier/orders', () {
    test('returns 401 UNAUTHORIZED when storeId is missing in token', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.post(
          Uri.parse('http://127.0.0.1/cashier/orders'),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: '{}',
        ),
      );
      when(() => context.read<TokenPayload>()).thenReturn(
        TokenPayload(
          id: 'cashier-id',
          role: AuthRole.cashier,
          tenantId: '550e8400-e29b-41d4-a716-446655440111',
        ),
      );

      final response = await route.onRequest(context);

      expect(response.statusCode, HttpStatus.unauthorized);
      final body = await response.json() as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'UNAUTHORIZED');
    });

    test('returns 400 INVALID_JSON for malformed request body', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.post(
          Uri.parse('http://127.0.0.1/cashier/orders'),
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

      final response = await route.onRequest(context);

      expect(response.statusCode, HttpStatus.badRequest);
      final body = await response.json() as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'INVALID_JSON');
    });

    test('returns 403 STORE_SCOPE_MISMATCH on store mismatch', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.post(
          Uri.parse('http://127.0.0.1/cashier/orders'),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body:
              '{"storeId":"550e8400-e29b-41d4-a716-446655440999",'
              '"items":[]}',
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

      final response = await route.onRequest(context);

      expect(response.statusCode, HttpStatus.forbidden);
      final body = await response.json() as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'STORE_SCOPE_MISMATCH');
    });

    test('returns 400 INVALID_INPUT for invalid items payload', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.post(
          Uri.parse('http://127.0.0.1/cashier/orders'),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: '{"items":[]}',
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

      final response = await route.onRequest(context);

      expect(response.statusCode, HttpStatus.badRequest);
      final body = await response.json() as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'INVALID_INPUT');
    });

    test('returns 201 with calculated order totals on success', () async {
      final context = _MockRequestContext();
      final pool = _MockPool();
      when(() => context.request).thenReturn(
        Request.post(
          Uri.parse('http://127.0.0.1/cashier/orders'),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: [
            '{"notes":"Walk-in order","items":[',
            '{"menuItemId":"550e8400-e29b-41d4-a716-446655440001",',
            '"itemName":"Veg Burger","quantity":2,',
            '"unitPrice":79,"gstPercent":5}',
            ']}',
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
        () => pool.runTx<Map<String, dynamic>?>(any()),
      ).thenAnswer(
        (_) async => {
          'id': '550e8400-e29b-41d4-a716-446655440777',
          'storeId': '550e8400-e29b-41d4-a716-446655440222',
          'tenantId': '550e8400-e29b-41d4-a716-446655440111',
          'cashierId': 'cashier-id',
          'customerId': null,
          'orderNumber': 'ORD-20260406-0001',
          'source': 'walk_in',
          'status': 'pending',
          'subtotal': 158,
          'gstAmount': 7.9,
          'discountAmount': 0,
          'total': 165.9,
          'paymentStatus': 'pending',
          'notes': 'Walk-in order',
          'createdAt': '2026-04-06T10:30:00.000Z',
          'items': [
            {
              'menuItemId': '550e8400-e29b-41d4-a716-446655440001',
              'itemName': 'Veg Burger',
              'quantity': 2,
              'unitPrice': 79,
              'gstPercent': 5,
              'lineTotal': 158,
              'gstAmount': 7.9,
            },
          ],
        },
      );

      final response = await route.onRequest(context);

      expect(response.statusCode, HttpStatus.created);
      final body = await response.json() as Map<String, dynamic>;
      expect(body['success'], isTrue);
      expect(body['message'], 'Order created successfully.');

      final order =
          (body['data'] as Map<String, dynamic>)['order']
              as Map<String, dynamic>;
      expect(order['storeId'], '550e8400-e29b-41d4-a716-446655440222');
      expect(order['source'], 'walk_in');
      expect(order['status'], 'pending');
      expect(order['subtotal'], 158);
      expect(order['gstAmount'], 7.9);
      expect(order['total'], 165.9);

      final items = order['items'] as List;
      expect(items, hasLength(1));
      expect((items.first as Map<String, dynamic>)['lineTotal'], 158);
    });

    test('returns 500 ORDER_CREATION_FAILED on repository exception', () async {
      final context = _MockRequestContext();
      final pool = _MockPool();
      when(() => context.request).thenReturn(
        Request.post(
          Uri.parse('http://127.0.0.1/cashier/orders'),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: [
            '{"items":[',
            '{"menuItemId":"550e8400-e29b-41d4-a716-446655440001",',
            '"itemName":"Veg Burger","quantity":1,"unitPrice":79}',
            ']}',
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
        () => pool.runTx<Map<String, dynamic>?>(any()),
      ).thenThrow(Exception('db error'));

      final response = await route.onRequest(context);

      expect(response.statusCode, HttpStatus.internalServerError);
      final body = await response.json() as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'ORDER_CREATION_FAILED');
    });
  });
}
