import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pos_server/enums/auth_role.dart';
import 'package:pos_server/models/token_payload.dart';
import 'package:pos_server/services/auth_service.dart';
import 'package:test/test.dart';

import '../../../routes/auth/refresh.dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

void main() {
  group('GET /auth/refresh', () {
    test('responds with a 405 when the request method is not POST', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.get(Uri.parse('http://127.0.0.1/auth/refresh')),
      );

      final response = await route.onRequest(context);

      expect(response.statusCode, HttpStatus.methodNotAllowed);

      final body = await response.json() as Map<String, dynamic>;
      final code = (body['error'] as Map<String, dynamic>)['code'] as String;
      expect(code, 'METHOD_NOT_ALLOWED');
    });
  });

  group('POST /auth/refresh', () {
    test(
      'uses refresh_token cookie even when body JSON is malformed',
      () async {
        final context = _MockRequestContext();
        final refreshToken = AuthService.generateRefreshToken(
          TokenPayload(id: 'test-user-id', role: AuthRole.merchant),
        );

        when(() => context.request).thenReturn(
          Request.post(
            Uri.parse('http://127.0.0.1/auth/refresh'),
            headers: {
              HttpHeaders.cookieHeader: 'refresh_token=$refreshToken',
              HttpHeaders.contentTypeHeader: 'application/json',
            },
            body: '{invalid',
          ),
        );

        final response = await route.onRequest(context);

        expect(response.statusCode, HttpStatus.ok);

        final body = await response.json() as Map<String, dynamic>;
        expect(body['success'], isTrue);
      },
    );
  });
}
