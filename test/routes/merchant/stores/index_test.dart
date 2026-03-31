import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pos_server/enums/auth_role.dart';
import 'package:pos_server/models/token_payload.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

import '../../../../routes/merchant/stores/index.dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

class _MockPool extends Mock implements Pool<String> {}

class _MockResultRow extends Mock implements ResultRow {}

void main() {
  group('PUT /merchant/stores', () {
    test('responds with a 405 when method is not allowed', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.put(Uri.parse('http://127.0.0.1/merchant/stores')),
      );

      final response = await route.onRequest(context);

      expect(response.statusCode, HttpStatus.methodNotAllowed);

      final body = await response.json() as Map<String, dynamic>;
      final code = (body['error'] as Map<String, dynamic>)['code'] as String;
      expect(code, 'METHOD_NOT_ALLOWED');
    });
  });

  group('GET /merchant/stores', () {
    test(
      'returns 401 UNAUTHORIZED when tenantId is missing in token',
      () async {
        final context = _MockRequestContext();
        final pool = _MockPool();
        when(() => context.request).thenReturn(
          Request.get(Uri.parse('http://127.0.0.1/merchant/stores')),
        );
        when(() => context.read<TokenPayload>()).thenReturn(
          TokenPayload(
            id: 'user-id',
            role: AuthRole.merchant,
          ),
        );
        when(() => context.read<Pool<String>>()).thenReturn(pool);

        final response = await route.onRequest(context);

        expect(response.statusCode, HttpStatus.unauthorized);

        final body = await response.json() as Map<String, dynamic>;
        final error = body['error'] as Map<String, dynamic>;
        expect(error['code'], 'UNAUTHORIZED');
      },
    );

    test('returns 500 STORES_FETCH_FAILED on repository exception', () async {
      final context = _MockRequestContext();
      final pool = _MockPool();

      when(() => context.request).thenReturn(
        Request.get(Uri.parse('http://127.0.0.1/merchant/stores')),
      );
      when(() => context.read<TokenPayload>()).thenReturn(
        TokenPayload(
          id: 'user-id',
          role: AuthRole.merchant,
          tenantId: '550e8400-e29b-41d4-a716-446655440111',
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
      expect(error['code'], 'STORES_FETCH_FAILED');
    });

    test('returns 200 with stores list for tenant', () async {
      final context = _MockRequestContext();
      final pool = _MockPool();
      final row = _MockResultRow();
      final result = Result(
        rows: [row],
        affectedRows: 1,
        schema: ResultSchema([]),
      );

      when(() => context.request).thenReturn(
        Request.get(Uri.parse('http://127.0.0.1/merchant/stores')),
      );
      when(() => context.read<TokenPayload>()).thenReturn(
        TokenPayload(
          id: 'user-id',
          role: AuthRole.merchant,
          tenantId: '550e8400-e29b-41d4-a716-446655440111',
        ),
      );
      when(() => context.read<Pool<String>>()).thenReturn(pool);
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

      final response = await route.onRequest(context);

      expect(response.statusCode, HttpStatus.ok);

      final body = await response.json() as Map<String, dynamic>;
      expect(body['success'], isTrue);
      expect(body['message'], 'Stores fetched successfully.');
      final stores = (body['data'] as Map<String, dynamic>)['stores'] as List;
      expect(stores, hasLength(1));
      expect(
        (stores.first as Map<String, dynamic>)['tenantId'],
        '550e8400-e29b-41d4-a716-446655440111',
      );
    });
  });
}
