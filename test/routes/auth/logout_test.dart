import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../routes/auth/logout.dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

void main() {
  group('GET /auth/logout', () {
    test('responds with a 405 when the request method is not POST', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.get(Uri.parse('http://127.0.0.1/auth/logout')),
      );

      final response = await route.onRequest(context);

      expect(response.statusCode, HttpStatus.methodNotAllowed);

      final body = await response.json() as Map<String, dynamic>;
      final code = (body['error'] as Map<String, dynamic>)['code'] as String;
      expect(code, 'METHOD_NOT_ALLOWED');
    });
  });

  group('POST /auth/logout', () {
    test('clears access and refresh token cookies', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.post(Uri.parse('http://127.0.0.1/auth/logout')),
      );

      final response = await route.onRequest(context);

      expect(response.statusCode, HttpStatus.ok);

      final setCookie = response.headers[HttpHeaders.setCookieHeader];
      expect(setCookie, isNotNull);
      expect(setCookie, contains('access_token='));
      expect(setCookie, contains('refresh_token='));
      expect(setCookie, contains('Max-Age=0'));
    });
  });
}
