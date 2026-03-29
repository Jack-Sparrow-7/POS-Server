import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

import '../../../../routes/admin/tenants/[id].dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

class _MockPool extends Mock implements Pool<String> {}

class _MockResult extends Mock implements Result {}

class _MockResultRow extends Mock implements ResultRow {}

void main() {
  group('DELETE /admin/tenants/:id', () {
    test('responds with a 405 when method is not allowed', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.delete(Uri.parse('http://127.0.0.1/admin/tenants/tenant-id')),
      );

      final response = await route.onRequest(context, 'tenant-id');

      expect(response.statusCode, HttpStatus.methodNotAllowed);

      final body = await response.json() as Map<String, dynamic>;
      final code = (body['error'] as Map<String, dynamic>)['code'] as String;
      expect(code, 'METHOD_NOT_ALLOWED');
    });
  });

  group('PATCH /admin/tenants/:id', () {
    test('returns 400 when no updatable fields are provided', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.patch(
          Uri.parse(
            'http://127.0.0.1/admin/tenants/550e8400-e29b-41d4-a716-446655440000',
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

    test('returns 404 TENANT_NOT_FOUND when tenant does not exist', () async {
      final context = _MockRequestContext();
      final pool = _MockPool();
      final result = _MockResult();

      when(() => context.request).thenReturn(
        Request.patch(
          Uri.parse(
            'http://127.0.0.1/admin/tenants/550e8400-e29b-41d4-a716-446655440000',
          ),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: '{"name":"Updated Name"}',
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
      expect(error['code'], 'TENANT_NOT_FOUND');
      expect(error['message'], 'Tenant not found.');
    });

    test('returns 200 with updated tenant on successful update', () async {
      final context = _MockRequestContext();
      final pool = _MockPool();
      final result = _MockResult();
      final row = _MockResultRow();

      when(() => context.request).thenReturn(
        Request.patch(
          Uri.parse(
            'http://127.0.0.1/admin/tenants/550e8400-e29b-41d4-a716-446655440000',
          ),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: '{"name":"Updated Name"}',
        ),
      );
      when(() => context.read<Pool<String>>()).thenReturn(pool);
      when(() => result.isEmpty).thenReturn(false);
      when(() => result.first).thenReturn(row);
      when(
        row.toColumnMap,
      ).thenReturn({
        'id': '550e8400-e29b-41d4-a716-446655440000',
        'name': 'Updated Name',
        'email': 'owner@acme.com',
        'phone': '9876543210',
        'address': '123 Main St',
        'city': 'Chennai',
        'state': 'Tamil Nadu',
        'pincode': '600001',
        'is_active': true,
        'created_at': DateTime.parse('2026-01-01T00:00:00Z'),
        'updated_at': DateTime.parse('2026-03-29T00:00:00Z'),
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
      expect(body['message'], 'Tenant updated successfully.');
      final tenant =
          (body['data'] as Map<String, dynamic>)['tenant']
              as Map<String, dynamic>;
      expect(tenant['name'], 'Updated Name');
    });
  });
}
