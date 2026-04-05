import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pos_server/enums/auth_role.dart';
import 'package:pos_server/models/token_payload.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

import '../../../../routes/cashier/menu_items/[id].dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

class _MockPool extends Mock implements Pool<String> {}

class _MockResult extends Mock implements Result {}

class _MockResultRow extends Mock implements ResultRow {}

void main() {
  group('POST /cashier/menu_items/:id', () {
    test('responds with a 405 when method is not allowed', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.post(
          Uri.parse('http://127.0.0.1/cashier/menu_items/menu-item-id'),
        ),
      );

      final response = await route.onRequest(context, 'menu-item-id');

      expect(response.statusCode, HttpStatus.methodNotAllowed);
      final body = await response.json() as Map<String, dynamic>;
      final code = (body['error'] as Map<String, dynamic>)['code'] as String;
      expect(code, 'METHOD_NOT_ALLOWED');
    });
  });

  group('GET /cashier/menu_items/:id', () {
    test('returns 400 INVALID_UUID for malformed menu item id', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.get(
          Uri.parse('http://127.0.0.1/cashier/menu_items/not-a-uuid'),
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
              'http://127.0.0.1/cashier/menu_items/550e8400-e29b-41d4-a716-446655440000',
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

    test(
      'returns 500 MENU_ITEM_FETCH_FAILED on repository exception',
      () async {
        final context = _MockRequestContext();
        final pool = _MockPool();

        when(() => context.request).thenReturn(
          Request.get(
            Uri.parse(
              'http://127.0.0.1/cashier/menu_items/550e8400-e29b-41d4-a716-446655440000',
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
        expect(error['code'], 'MENU_ITEM_FETCH_FAILED');
      },
    );

    test(
      'returns 404 MENU_ITEM_NOT_FOUND when menu item does not exist',
      () async {
        final context = _MockRequestContext();
        final pool = _MockPool();
        final result = _MockResult();

        when(() => context.request).thenReturn(
          Request.get(
            Uri.parse(
              'http://127.0.0.1/cashier/menu_items/550e8400-e29b-41d4-a716-446655440000',
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
        expect(error['code'], 'MENU_ITEM_NOT_FOUND');
      },
    );

    test('returns 200 with menu item on successful fetch', () async {
      final context = _MockRequestContext();
      final pool = _MockPool();
      final result = _MockResult();
      final row = _MockResultRow();

      when(() => context.request).thenReturn(
        Request.get(
          Uri.parse(
            'http://127.0.0.1/cashier/menu_items/550e8400-e29b-41d4-a716-446655440000',
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
      when(() => result.isEmpty).thenReturn(false);
      when(() => result.first).thenReturn(row);
      when(row.toColumnMap).thenReturn({
        'id': '550e8400-e29b-41d4-a716-446655440000',
        'store_id': '550e8400-e29b-41d4-a716-446655440222',
        'name': 'Veg Burger',
        'description': 'Classic burger',
        'category_id': null,
        'counter_id': null,
        'cost_price': 40,
        'price': 79,
        'gst_percent': 5,
        'hsn_code': null,
        'is_available': true,
        'stock_count': null,
        'track_stock': false,
        'sort_order': 1,
        'image_url': null,
        'created_at': DateTime.parse('2026-03-01T00:00:00Z'),
        'updated_at': DateTime.parse('2026-03-15T00:00:00Z'),
      });
      when(
        () => pool.execute(any(), parameters: any(named: 'parameters')),
      ).thenAnswer((_) async => result);

      final response = await route.onRequest(
        context,
        '550e8400-e29b-41d4-a716-446655440000',
      );

      expect(response.statusCode, HttpStatus.ok);
      final body = await response.json() as Map<String, dynamic>;
      expect(body['success'], isTrue);
      expect(body['message'], 'Menu item fetched successfully.');
      final menuItem =
          (body['data'] as Map<String, dynamic>)['menuItem']
              as Map<String, dynamic>;
      expect(menuItem['name'], 'Veg Burger');
      expect(menuItem['price'], 79);
    });
  });
}
