import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pos_server/enums/auth_role.dart';
import 'package:pos_server/models/token_payload.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

import '../../../../routes/cashier/menu_items/index.dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

class _MockPool extends Mock implements Pool<String> {}

class _MockResultRow extends Mock implements ResultRow {}

void main() {
  group('POST /cashier/menu_items', () {
    test('responds with a 405 when method is not allowed', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.post(Uri.parse('http://127.0.0.1/cashier/menu_items')),
      );

      final response = await route.onRequest(context);

      expect(response.statusCode, HttpStatus.methodNotAllowed);
      final body = await response.json() as Map<String, dynamic>;
      final code = (body['error'] as Map<String, dynamic>)['code'] as String;
      expect(code, 'METHOD_NOT_ALLOWED');
    });
  });

  group('GET /cashier/menu_items', () {
    test(
      'returns 401 UNAUTHORIZED when storeId is missing in token',
      () async {
        final context = _MockRequestContext();
        when(() => context.request).thenReturn(
          Request.get(Uri.parse('http://127.0.0.1/cashier/menu_items')),
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
      },
    );

    test('returns 400 INVALID_INPUT for malformed isAvailable', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.get(
          Uri.parse('http://127.0.0.1/cashier/menu_items?isAvailable=maybe'),
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

    test('returns 400 INVALID_UUID for malformed categoryId', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.get(
          Uri.parse('http://127.0.0.1/cashier/menu_items?categoryId=bad'),
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
      expect(error['code'], 'INVALID_UUID');
    });

    test('returns 400 INVALID_UUID for malformed counterId', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.get(
          Uri.parse('http://127.0.0.1/cashier/menu_items?counterId=bad'),
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
      expect(error['code'], 'INVALID_UUID');
    });

    test(
      'returns 500 MENU_ITEMS_FETCH_FAILED on repository exception',
      () async {
        final context = _MockRequestContext();
        final pool = _MockPool();

        when(() => context.request).thenReturn(
          Request.get(Uri.parse('http://127.0.0.1/cashier/menu_items')),
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
        expect(error['code'], 'MENU_ITEMS_FETCH_FAILED');
      },
    );

    test('returns 200 with menu items list', () async {
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
            'http://127.0.0.1/cashier/menu_items'
            '?categoryId=550e8400-e29b-41d4-a716-446655440333'
            '&counterId=550e8400-e29b-41d4-a716-446655440444',
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
        'id': '550e8400-e29b-41d4-a716-446655440001',
        'store_id': '550e8400-e29b-41d4-a716-446655440222',
        'name': 'Veg Burger',
        'description': 'Classic burger',
        'category_id': null,
        'counter_id': null,
        'cost_price': 40,
        'price': 79,
        'gst_percent': 5,
        'hsn_code': '2106',
        'is_available': true,
        'stock_count': 10,
        'track_stock': true,
        'sort_order': 1,
        'image_url': null,
        'created_at': DateTime.parse('2026-03-01T00:00:00Z'),
        'updated_at': DateTime.parse('2026-03-15T00:00:00Z'),
      });
      when(
        () => pool.execute(any(), parameters: any(named: 'parameters')),
      ).thenAnswer((_) async => result);

      final response = await route.onRequest(context);

      expect(response.statusCode, HttpStatus.ok);
      final body = await response.json() as Map<String, dynamic>;
      expect(body['success'], isTrue);
      expect(body['message'], 'Menu items fetched successfully.');
      final menuItems =
          (body['data'] as Map<String, dynamic>)['menuItems'] as List;
      expect(menuItems, hasLength(1));
      expect((menuItems.first as Map<String, dynamic>)['name'], 'Veg Burger');
    });
  });
}
