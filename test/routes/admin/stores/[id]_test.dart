import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

import '../../../../routes/admin/stores/[id].dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

class _MockPool extends Mock implements Pool<String> {}

class _MockResult extends Mock implements Result {}

class _MockResultRow extends Mock implements ResultRow {}

void main() {
  group('DELETE /admin/stores/:id', () {
    test('responds with a 405 when method is not allowed', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.delete(Uri.parse('http://127.0.0.1/admin/stores/store-id')),
      );

      final response = await route.onRequest(context, 'store-id');

      expect(response.statusCode, HttpStatus.methodNotAllowed);

      final body = await response.json() as Map<String, dynamic>;
      final code = (body['error'] as Map<String, dynamic>)['code'] as String;
      expect(code, 'METHOD_NOT_ALLOWED');
    });
  });

  group('GET /admin/stores/:id', () {
    test('returns 400 INVALID_UUID for malformed store id', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.get(Uri.parse('http://127.0.0.1/admin/stores/not-a-uuid')),
      );

      final response = await route.onRequest(context, 'not-a-uuid');

      expect(response.statusCode, HttpStatus.badRequest);

      final body = await response.json() as Map<String, dynamic>;
      final code = (body['error'] as Map<String, dynamic>)['code'] as String;
      expect(code, 'INVALID_UUID');
    });

    test('returns 404 STORE_NOT_FOUND when store does not exist', () async {
      final context = _MockRequestContext();
      final pool = _MockPool();
      final result = _MockResult();

      when(() => context.request).thenReturn(
        Request.get(
          Uri.parse(
            'http://127.0.0.1/admin/stores/550e8400-e29b-41d4-a716-446655440000',
          ),
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
            'http://127.0.0.1/admin/stores/550e8400-e29b-41d4-a716-446655440000',
          ),
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
      expect(body['message'], 'Store fetched successfully.');
      final store =
          (body['data'] as Map<String, dynamic>)['store']
              as Map<String, dynamic>;
      expect(store['name'], 'Main Store');
      expect(store['tenantName'], 'Acme Foods');
    });
  });

  group('PATCH /admin/stores/:id', () {
    test('returns 400 INVALID_JSON for malformed request body', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.patch(
          Uri.parse(
            'http://127.0.0.1/admin/stores/550e8400-e29b-41d4-a716-446655440000',
          ),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: '{invalid',
        ),
      );

      final response = await route.onRequest(
        context,
        '550e8400-e29b-41d4-a716-446655440000',
      );

      expect(response.statusCode, HttpStatus.badRequest);

      final body = await response.json() as Map<String, dynamic>;
      final code = (body['error'] as Map<String, dynamic>)['code'] as String;
      expect(code, 'INVALID_JSON');
    });

    test('returns 400 when no updatable fields are provided', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.patch(
          Uri.parse(
            'http://127.0.0.1/admin/stores/550e8400-e29b-41d4-a716-446655440000',
          ),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: '{}',
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
      expect(
        error['message'],
        'At least one field must be provided for update.',
      );
    });

    test('returns 400 for invalid subscription status', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.patch(
          Uri.parse(
            'http://127.0.0.1/admin/stores/550e8400-e29b-41d4-a716-446655440000',
          ),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: '{"subscriptionStatus":"invalid-status"}',
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

    test('returns 400 for invalid datetime format', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.patch(
          Uri.parse(
            'http://127.0.0.1/admin/stores/550e8400-e29b-41d4-a716-446655440000',
          ),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: '{"subscriptionExpiresAt":"not-a-date"}',
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
      final details = error['details'] as Map<String, dynamic>;
      expect(details.containsKey('subscriptionExpiresAt'), isTrue);
    });

    test('returns 404 STORE_NOT_FOUND when store does not exist', () async {
      final context = _MockRequestContext();
      final pool = _MockPool();
      final result = _MockResult();

      when(() => context.request).thenReturn(
        Request.patch(
          Uri.parse(
            'http://127.0.0.1/admin/stores/550e8400-e29b-41d4-a716-446655440000',
          ),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: '{"isActive":false}',
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
      expect(error['code'], 'STORE_NOT_FOUND');
      expect(error['message'], 'Store not found.');
    });

    test('returns 200 with updated store on successful update', () async {
      final context = _MockRequestContext();
      final pool = _MockPool();
      final result = _MockResult();
      final row = _MockResultRow();

      when(() => context.request).thenReturn(
        Request.patch(
          Uri.parse(
            'http://127.0.0.1/admin/stores/550e8400-e29b-41d4-a716-446655440000',
          ),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body:
              '{"subscriptionStatus":"active","phonepeConfigured":true,"isActive":true}',
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
        'subscription_status': 'active',
        'subscription_started_at': DateTime.parse('2026-03-01T00:00:00Z'),
        'subscription_expires_at': DateTime.parse('2026-04-01T00:00:00Z'),
        'trial_expires_at': DateTime.parse('2026-04-10T00:00:00Z'),
        'phonepe_client_id': null,
        'phonepe_client_version': 1,
        'phonepe_client_secret': null,
        'phonepe_configured': true,
        'gst_enabled': true,
        'is_open': true,
        'is_active': true,
        'created_at': DateTime.parse('2026-03-01T00:00:00Z'),
        'updated_at': DateTime.parse('2026-03-20T00:00:00Z'),
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
      expect(body['message'], 'Store updated successfully.');
      final store =
          (body['data'] as Map<String, dynamic>)['store']
              as Map<String, dynamic>;
      expect(store['subscriptionStatus'], 'active');
      expect(store['phonepeConfigured'], isTrue);
    });
  });
}
