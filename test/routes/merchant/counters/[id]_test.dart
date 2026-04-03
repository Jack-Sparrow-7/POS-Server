import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pos_server/enums/auth_role.dart';
import 'package:pos_server/models/token_payload.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

import '../../../../routes/merchant/counters/[id].dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

class _MockPool extends Mock implements Pool<String> {}

class _MockResult extends Mock implements Result {}

class _MockResultRow extends Mock implements ResultRow {}

void main() {
  group('DELETE /merchant/counters/:id', () {
    test('responds with a 405 when method is not allowed', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.delete(
          Uri.parse('http://127.0.0.1/merchant/counters/counter-id'),
        ),
      );

      final response = await route.onRequest(context, 'counter-id');

      expect(response.statusCode, HttpStatus.methodNotAllowed);

      final body = await response.json() as Map<String, dynamic>;
      final code = (body['error'] as Map<String, dynamic>)['code'] as String;
      expect(code, 'METHOD_NOT_ALLOWED');
    });
  });

  group('GET /merchant/counters/:id', () {
    test('returns 400 INVALID_UUID for malformed counter id', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.get(Uri.parse('http://127.0.0.1/merchant/counters/not-a-uuid')),
      );

      final response = await route.onRequest(context, 'not-a-uuid');

      expect(response.statusCode, HttpStatus.badRequest);

      final body = await response.json() as Map<String, dynamic>;
      final code = (body['error'] as Map<String, dynamic>)['code'] as String;
      expect(code, 'INVALID_UUID');
    });

    test('returns 401 UNAUTHORIZED when tenantId is missing in token', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.get(
          Uri.parse(
            'http://127.0.0.1/merchant/counters/550e8400-e29b-41d4-a716-446655440000',
          ),
        ),
      );
      when(() => context.read<TokenPayload>()).thenReturn(
        TokenPayload(id: 'user-id', role: AuthRole.merchant),
      );

      final response = await route.onRequest(
        context,
        '550e8400-e29b-41d4-a716-446655440000',
      );

      expect(response.statusCode, HttpStatus.unauthorized);

      final body = await response.json() as Map<String, dynamic>;
      final code = (body['error'] as Map<String, dynamic>)['code'] as String;
      expect(code, 'UNAUTHORIZED');
    });

    test('returns 404 COUNTER_NOT_FOUND when counter does not exist', () async {
      final context = _MockRequestContext();
      final pool = _MockPool();
      final result = _MockResult();

      when(() => context.request).thenReturn(
        Request.get(
          Uri.parse(
            'http://127.0.0.1/merchant/counters/550e8400-e29b-41d4-a716-446655440000',
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
      expect(code, 'COUNTER_NOT_FOUND');
    });

    test('returns 200 with counter on successful fetch', () async {
      final context = _MockRequestContext();
      final pool = _MockPool();
      final result = _MockResult();
      final row = _MockResultRow();

      when(() => context.request).thenReturn(
        Request.get(
          Uri.parse(
            'http://127.0.0.1/merchant/counters/550e8400-e29b-41d4-a716-446655440000',
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
        'store_id': '550e8400-e29b-41d4-a716-446655440222',
        'name': 'Kitchen',
        'description': 'Main kitchen counter',
        'is_active': true,
        'sort_order': 0,
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
      expect(body['message'], 'Counter fetched successfully.');
      final counter =
          (body['data'] as Map<String, dynamic>)['counter']
              as Map<String, dynamic>;
      expect(counter['name'], 'Kitchen');
    });
  });

  group('PATCH /merchant/counters/:id', () {
    test('returns 400 INVALID_JSON for malformed request body', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.patch(
          Uri.parse(
            'http://127.0.0.1/merchant/counters/550e8400-e29b-41d4-a716-446655440000',
          ),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: '{invalid',
        ),
      );
      when(() => context.read<TokenPayload>()).thenReturn(
        TokenPayload(
          id: 'user-id',
          role: AuthRole.merchant,
          tenantId: '550e8400-e29b-41d4-a716-446655440111',
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

    test('returns 400 when no updatable fields are provided', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.patch(
          Uri.parse(
            'http://127.0.0.1/merchant/counters/550e8400-e29b-41d4-a716-446655440000',
          ),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: '{}',
        ),
      );
      when(() => context.read<TokenPayload>()).thenReturn(
        TokenPayload(
          id: 'user-id',
          role: AuthRole.merchant,
          tenantId: '550e8400-e29b-41d4-a716-446655440111',
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

    test('returns 404 COUNTER_NOT_FOUND when counter does not exist', () async {
      final context = _MockRequestContext();
      final pool = _MockPool();
      final result = _MockResult();

      when(() => context.request).thenReturn(
        Request.patch(
          Uri.parse(
            'http://127.0.0.1/merchant/counters/550e8400-e29b-41d4-a716-446655440000',
          ),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: '{"name":"Bar"}',
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

      final body = await response.json() as Map<String, dynamic>;
      expect(response.statusCode, HttpStatus.notFound);
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'COUNTER_NOT_FOUND');
    });

    test('returns 409 COUNTER_NAME_EXISTS on duplicate counter name', () async {
      final context = _MockRequestContext();
      final pool = _MockPool();

      when(() => context.request).thenReturn(
        Request.patch(
          Uri.parse(
            'http://127.0.0.1/merchant/counters/550e8400-e29b-41d4-a716-446655440000',
          ),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: '{"name":"Kitchen"}',
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
      when(
        () => pool.execute(any(), parameters: any(named: 'parameters')),
      ).thenThrow(
        Exception(
          'duplicate key value violates unique constraint counters_name_store_unique',
        ),
      );

      final response = await route.onRequest(
        context,
        '550e8400-e29b-41d4-a716-446655440000',
      );

      final body = await response.json() as Map<String, dynamic>;
      expect(response.statusCode, HttpStatus.conflict);
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'COUNTER_NAME_EXISTS');
    });

    test('returns 200 with updated counter on successful update', () async {
      final context = _MockRequestContext();
      final pool = _MockPool();
      final result = _MockResult();
      final row = _MockResultRow();

      when(() => context.request).thenReturn(
        Request.patch(
          Uri.parse(
            'http://127.0.0.1/merchant/counters/550e8400-e29b-41d4-a716-446655440000',
          ),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: '{"name":"Bar","sortOrder":2,"isActive":true}',
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
        'store_id': '550e8400-e29b-41d4-a716-446655440222',
        'name': 'Bar',
        'description': 'Main kitchen counter',
        'is_active': true,
        'sort_order': 2,
        'created_at': DateTime.parse('2026-03-01T00:00:00Z'),
        'updated_at': DateTime.parse('2026-03-20T00:00:00Z'),
      });
      when(
        () => pool.execute(any(), parameters: any(named: 'parameters')),
      ).thenAnswer((_) async => result);

      final response = await route.onRequest(
        context,
        '550e8400-e29b-41d4-a716-446655440000',
      );

      final body = await response.json() as Map<String, dynamic>;
      expect(response.statusCode, HttpStatus.ok);
      expect(body['success'], isTrue);
      expect(body['message'], 'Counter updated successfully.');
      final counter =
          (body['data'] as Map<String, dynamic>)['counter']
              as Map<String, dynamic>;
      expect(counter['name'], 'Bar');
      expect(counter['sortOrder'], 2);
    });
  });
}
