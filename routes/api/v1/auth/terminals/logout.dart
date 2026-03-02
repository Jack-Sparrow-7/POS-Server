import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:pos_backend/utils/auth_cookies.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != .get && context.request.method != .post) {
    return Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {'status': 'error', 'message': 'Method not allowed.'},
    );
  }

  return Response.json(
    body: {
      'status': 'success',
      'message': 'Terminal logged out successfully.',
    },
    headers: {HttpHeaders.setCookieHeader: buildClearAuthCookiesHeaders()},
  );
}
