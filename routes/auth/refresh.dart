import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:pos_server/exceptions/auth_exception.dart';
import 'package:pos_server/models/token_payload.dart';
import 'package:pos_server/services/auth_service.dart';
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
  late final Map<String, dynamic> body;
  late final TokenPayload payload;
  String? refreshToken;

  refreshToken = AuthService.extractRefreshTokenFromCookies(
    context.request.headers[HttpHeaders.cookieHeader],
  );

  if (refreshToken == null) {
    try {
      body = await context.request.json() as Map<String, dynamic>;
      refreshToken = (body['refreshToken'] as String?)?.trim();
    } catch (e) {
      return ResponseHelper.problem(
        statusCode: HttpStatus.badRequest,
        code: 'INVALID_JSON',
        message: 'The request body must be a valid JSON object.',
      );
    }
  }

  if (refreshToken == null || refreshToken.isEmpty) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_INPUT',
      message: 'Refresh token is required.',
    );
  }

  try {
    payload = AuthService.verifyRefreshToken(refreshToken);
  } on AuthException catch (e) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.unauthorized,
      code: 'INVALID_REFRESH_TOKEN',
      message: e.message,
    );
  } catch (e) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.unauthorized,
      code: 'INVALID_REFRESH_TOKEN',
      message: 'Invalid or expired refresh token.',
    );
  }

  final tokens = AuthService.generateTokens(payload);

  final accessTokenCookie = AuthService.buildAccessTokenCookie(
    tokens.accessToken,
  );
  final refreshTokenCookie = AuthService.buildRefreshTokenCookie(
    tokens.refreshToken,
  );

  return ResponseHelper.success(
    headers: {
      HttpHeaders.setCookieHeader: [
        accessTokenCookie,
        refreshTokenCookie,
      ],
    },
    message: 'Token refreshed successfully.',
    data: {
      'accessToken': tokens.accessToken,
      'refreshToken': tokens.refreshToken,
    },
  );
}
