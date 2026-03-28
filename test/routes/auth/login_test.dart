import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../routes/auth/login.dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

void main() async {
  group('GET /auth/login', () {
    test('responds with a 405 when the request method is not POST', () async {
      final context = _MockRequestContext();
      when(
        () => context.request,
      ).thenReturn(Request.get(Uri.parse('http://127.0.0.1/auth/login')));
      final response = await route.onRequest(context);

      expect(response.statusCode, HttpStatus.methodNotAllowed);

      final body = await response.json() as Map<String, dynamic>;
      final code = (body['error'] as Map<String, dynamic>)['code'] as String;
      expect(code, 'METHOD_NOT_ALLOWED');
    });
  });

  group('POST /auth/login', () {
    test('responds with a 400 when the request is invalid', () async {
      final context = _MockRequestContext();
      when(
        () => context.request,
      ).thenReturn(
        Request.post(
          Uri.parse('http://127.0.0.1/auth/login'),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: '{}'
        ),
      );
      final response = await route.onRequest(context);

      expect(response.statusCode, HttpStatus.badRequest);

      final body = await response.json() as Map<String, dynamic>;
      final code = (body['error'] as Map<String, dynamic>)['code'] as String;
      expect(code, 'INVALID_INPUT');
    });

    test('responds with a 400 when the request is invalid', () async {
      final context = _MockRequestContext();
      when(
        () => context.request,
      ).thenReturn(
        Request.post(
          Uri.parse('http://127.0.0.1/auth/login'),
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
  });
}
