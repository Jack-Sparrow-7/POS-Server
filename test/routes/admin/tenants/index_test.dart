import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

import '../../../../routes/admin/tenants/index.dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

class _MockPool extends Mock implements Pool<String> {}

void main() {
  group('PUT /admin/tenants', () {
    test('responds with a 405 when method is not allowed', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.put(Uri.parse('http://127.0.0.1/admin/tenants')),
      );

      final response = await route.onRequest(context);

      expect(response.statusCode, HttpStatus.methodNotAllowed);

      final body = await response.json() as Map<String, dynamic>;
      final code = (body['error'] as Map<String, dynamic>)['code'] as String;
      expect(code, 'METHOD_NOT_ALLOWED');
    });
  });

  group('POST /admin/tenants', () {
    test('returns 400 INVALID_JSON for malformed request body', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.post(
          Uri.parse('http://127.0.0.1/admin/tenants'),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: '{invalid',
        ),
      );

      final response = await route.onRequest(context);

      expect(response.statusCode, HttpStatus.badRequest);

      final body = await response.json() as Map<String, dynamic>;
      final code = (body['error'] as Map<String, dynamic>)['code'] as String;
      expect(code, 'INVALID_JSON');
    });

    test('returns 409 TENANT_EMAIL_EXISTS on duplicate email', () async {
      final context = _MockRequestContext();
      final pool = _MockPool();

      when(() => context.request).thenReturn(
        Request.post(
          Uri.parse('http://127.0.0.1/admin/tenants'),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: '{"name":"Acme","email":"owner@acme.com","phone":"9876543210"}',
        ),
      );
      when(() => context.read<Pool<String>>()).thenReturn(pool);
      when(
        () => pool.execute(any(), parameters: any(named: 'parameters')),
      ).thenThrow(
        Exception(
          'duplicate key value violates unique constraint tenants_email_key',
        ),
      );

      final response = await route.onRequest(context);

      expect(response.statusCode, HttpStatus.conflict);

      final body = await response.json() as Map<String, dynamic>;
      final code = (body['error'] as Map<String, dynamic>)['code'] as String;
      expect(code, 'TENANT_EMAIL_EXISTS');
    });

    test('accepts optional fields in payload (passes validation)', () async {
      final context = _MockRequestContext();
      final pool = _MockPool();

      when(() => context.request).thenReturn(
        Request.post(
          Uri.parse('http://127.0.0.1/admin/tenants'),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body:
              '{"name":"Acme","email":"owner@acme.com","phone":"9876543210",'
              '''
              "address":"123 Main St","city":"Chennai","state":"Tamil Nadu","pincode":"600001"}''',
        ),
      );
      when(() => context.read<Pool<String>>()).thenReturn(pool);
      when(
        () => pool.execute(any(), parameters: any(named: 'parameters')),
      ).thenThrow(Exception('temporary db failure'));

      final response = await route.onRequest(context);

      expect(response.statusCode, HttpStatus.internalServerError);

      final body = await response.json() as Map<String, dynamic>;
      final code = (body['error'] as Map<String, dynamic>)['code'] as String;
      expect(code, 'TENANT_CREATION_FAILED');
    });
  });
}
