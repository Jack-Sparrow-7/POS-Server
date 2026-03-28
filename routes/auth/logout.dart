import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:pos_server/utils/response_helper.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == .post) {
    return _onPost(context);
  }

  return ResponseHelper.problem(
    statusCode: HttpStatus.methodNotAllowed,
    code: 'METHOD_NOT_ALLOWED',
    message: 'Method not allowed',
  );
}

Future<Response> _onPost(RequestContext context) async {
  final accessTokenCookie = Cookie('access_token', '')
    ..httpOnly = true
    ..path = '/'
    ..sameSite = .lax
    ..secure = false
    ..maxAge = 0;

  final refreshTokenCookie = Cookie('refresh_token', '')
    ..httpOnly = true
    ..path = '/'
    ..sameSite = .lax
    ..secure = false
    ..maxAge = 0;

  return ResponseHelper.success(
    headers: {
      HttpHeaders.setCookieHeader: [
        accessTokenCookie.toString(),
        refreshTokenCookie.toString(),
      ],
    },
    message: 'Logged out successfully',
  );
}
