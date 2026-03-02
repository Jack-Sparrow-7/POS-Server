import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:pos_backend/config/env.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != .get && context.request.method != .post) {
    return Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {'status': 'error', 'message': 'Method not allowed.'},
    );
  }

  final cookie = Cookie('access_token', '')
    ..httpOnly = true
    ..secure = Env.isProd
    ..path = '/'
    ..maxAge = 0
    ..sameSite = SameSite.lax;

  return Response.json(
    body: {
      'status': 'success',
      'message': 'Logged out successfully.',
    },
    headers: {HttpHeaders.setCookieHeader: cookie.toString()},
  );
}
