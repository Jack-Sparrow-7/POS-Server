import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pos_server/enums/auth_role.dart';
import 'package:pos_server/models/token_payload.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

import '../../../../routes/merchant/stores/[id].dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

class _MockPool extends Mock implements Pool<String> {}

class _MockResult extends Mock implements Result {}

class _MockResultRow extends Mock implements ResultRow {}

void main() {
  group('DELETE /merchant/stores/:id', () {
    test('responds with a 405 when method is not allowed', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.delete(Uri.parse('http://127.0.0.1/merchant/stores/store-id')),
      );

      final response = await route.onRequest(context, 'store-id');

      expect(response.statusCode, HttpStatus.methodNotAllowed);

      final body = await response.json() as Map<String, dynamic>;
      final code = (body['error'] as Map<String, dynamic>)['code'] as String;
      expect(code, 'METHOD_NOT_ALLOWED');
    });
  });

  group('GET /merchant/stores/:id', () {
    test('returns 400 INVALID_UUID for malformed store id', () async {
      final context = _MockRequestContext();
      final pool = _MockPool();
      when(() => context.request).thenReturn(
        Request.get(Uri.parse('http://127.0.0.1/merchant/stores/not-a-uuid')),
      );
      when(() => context.read<TokenPayload>()).thenReturn(
        TokenPayload(
          id: 'user-id',
          role: AuthRole.merchant,
          tenantId: '550e8400-e29b-41d4-a716-446655440111',
        ),
      );
      when(() => context.read<Pool<String>>()).thenReturn(pool);

      final response = await route.onRequest(context, 'not-a-uuid');

      expect(response.statusCode, HttpStatus.badRequest);

      final body = await response.json() as Map<String, dynamic>;
      final code = (body['error'] as Map<String, dynamic>)['code'] as String;
      expect(code, 'INVALID_UUID');
    });

    test(
      'returns 401 UNAUTHORIZED when tenantId is missing in token',
      () async {
        final context = _MockRequestContext();
        final pool = _MockPool();
        when(() => context.request).thenReturn(
          Request.get(
            Uri.parse(
              'http://127.0.0.1/merchant/stores/550e8400-e29b-41d4-a716-446655440000',
            ),
          ),
        );
        when(() => context.read<TokenPayload>()).thenReturn(
          TokenPayload(
            id: 'user-id',
            role: AuthRole.merchant,
          ),
        );
        when(() => context.read<Pool<String>>()).thenReturn(pool);

        final response = await route.onRequest(
          context,
          '550e8400-e29b-41d4-a716-446655440000',
        );

        expect(response.statusCode, HttpStatus.unauthorized);

        final body = await response.json() as Map<String, dynamic>;
        final code = (body['error'] as Map<String, dynamic>)['code'] as String;
        expect(code, 'UNAUTHORIZED');
      },
    );

    test('returns 404 STORE_NOT_FOUND when store does not exist', () async {
      final context = _MockRequestContext();
      final pool = _MockPool();
      final result = _MockResult();

      when(() => context.request).thenReturn(
        Request.get(
          Uri.parse(
            'http://127.0.0.1/merchant/stores/550e8400-e29b-41d4-a716-446655440000',
          ),
        ),
      );
      when(() => context.read<TokenPayload>()).thenReturn(
        TokenPayload(
          id: 'user-id',
          role: AuthRole.merchant,
          tenantId: '550e8400-e29b-41d4-a716-446655440111',
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
      final code = (body['error'] as Map<String, dynamic>)['code'] as String;
      expect(code, 'STORE_NOT_FOUND');
    });

    test('returns 200 with store on successful fetch', () async {
      final context = _MockRequestContext();
      final pool = _MockPool();
      final result = _MockResult();
      final row = _MockResultRow();

      when(() => context.request).thenReturn(
        Request.get(
          Uri.parse(
            'http://127.0.0.1/merchant/stores/550e8400-e29b-41d4-a716-446655440000',
          ),
        ),
      );
      when(() => context.read<TokenPayload>()).thenReturn(
        TokenPayload(
          id: 'user-id',
          role: AuthRole.merchant,
          tenantId: '550e8400-e29b-41d4-a716-446655440111',
        ),
      );
      when(() => context.read<Pool<String>>()).thenReturn(pool);
      when(() => result.isEmpty).thenReturn(false);
      when(() => result.first).thenReturn(row);
      when(row.toColumnMap).thenReturn({
        'id': '550e8400-e29b-41d4-a716-446655440000',
        'tenant_id': '550e8400-e29b-41d4-a716-446655440111',
        'name': 'Main Store',
        'slug': 'main-store',
        'description': 'Primary outlet',
        'address': '123 Main St',
        'city': 'Chennai',
        'state': 'Tamil Nadu',
        'pincode': '600001',
        'phone': '9876543210',
        'gstin': '33ABCDE1234F1Z5',
        'subscription_status': 'trial',
        'subscription_started_at': null,
        'subscription_expires_at': null,
        'trial_expires_at': DateTime.parse('2026-04-10T00:00:00Z'),
        'phonepe_client_id': null,
        'phonepe_client_version': 1,
        'phonepe_client_secret': null,
        'phonepe_configured': false,
        'gst_enabled': true,
        'is_open': true,
        'is_active': true,
        'created_at': DateTime.parse('2026-03-01T00:00:00Z'),
        'updated_at': DateTime.parse('2026-03-15T00:00:00Z'),
        'tenant_name': 'Acme Foods',
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
      expect(body['message'], 'Store details fetched successfully.');
      final store =
          (body['data'] as Map<String, dynamic>)['store']
              as Map<String, dynamic>;
      expect(store['id'], '550e8400-e29b-41d4-a716-446655440000');
      expect(store['tenantId'], '550e8400-e29b-41d4-a716-446655440111');
    });
  });
}
