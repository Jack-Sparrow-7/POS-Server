import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:loxia/loxia.dart';
import 'package:pos_backend/models/terminal/terminal.dart';
import 'package:pos_backend/services/jwt_service.dart';
import 'package:pos_backend/utils/auth_cookies.dart';
import 'package:pos_backend/utils/json_body_parser.dart';
import 'package:pos_backend/validators/terminal_validators.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != .post) {
    return Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {'status': 'error', 'message': 'Method not allowed.'},
    );
  }

  String? refreshToken;
  final contentType = context.request.headers['content-type'] ?? '';
  if (contentType.toLowerCase().contains('application/json')) {
    final parsedBody = await parseJsonObjectBody(context.request);
    if (parsedBody.errorResponse != null) {
      return parsedBody.errorResponse!;
    }

    final result = TerminalValidators.refreshSchema.tryParse(parsedBody.body!);
    if (!result.success) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {
          'status': 'error',
          'message': 'Request validation failed.',
          'errors': result.errors,
        },
      );
    }
    refreshToken = result.value['refreshToken'] as String?;
  }
  refreshToken ??= readCookieValue(context.request, 'refresh_token');
  if (refreshToken == null) {
    return Response.json(
      statusCode: HttpStatus.unauthorized,
      body: {'status': 'error', 'message': 'Refresh token is required.'},
    );
  }

  try {
    final payload = JwtService.verifyToken(token: refreshToken);
    final kind = payload['kind'] as String?;
    final type = payload['type'] as String?;
    final id = payload['sub'] as String?;
    final tokenVersionClaim = payload['tv'];
    final tokenVersion = switch (tokenVersionClaim) {
      final int value => value,
      final num value => value.toInt(),
      _ => null,
    };

    if (kind != 'refresh' || type != 'terminal' || id == null) {
      return Response.json(
        statusCode: HttpStatus.unauthorized,
        body: {'status': 'error', 'message': 'Invalid refresh token.'},
      );
    }

    final terminals = context.read<DataSource>().getRepository<Terminal>();
    final terminal = await terminals.findOneBy(
      where: TerminalQuery((t) => t.id.equals(id)),
    );

    if (terminal == null || !terminal.isActive) {
      return Response.json(
        statusCode: HttpStatus.unauthorized,
        body: {'status': 'error', 'message': 'Invalid refresh token.'},
      );
    }
    if (tokenVersion != null && tokenVersion != terminal.tokenVersion) {
      return Response.json(
        statusCode: HttpStatus.unauthorized,
        body: {'status': 'error', 'message': 'Invalid refresh token.'},
      );
    }

    final accessToken = JwtService.generateAccessToken(
      userId: terminal.id,
      type: 'terminal',
      tokenVersion: terminal.tokenVersion,
    );
    final nextRefreshToken = JwtService.generateRefreshToken(
      userId: terminal.id,
      type: 'terminal',
      tokenVersion: terminal.tokenVersion,
    );

    return Response.json(
      headers: {
        HttpHeaders.setCookieHeader: buildAuthSetCookieHeaders(
          accessToken: accessToken,
          refreshToken: nextRefreshToken,
        ),
      },
      body: {
        'status': 'success',
        'token': accessToken,
        'refreshToken': nextRefreshToken,
        'message': 'Token refreshed successfully.',
      },
    );
  } on JWTException {
    return Response.json(
      statusCode: HttpStatus.unauthorized,
      body: {'status': 'error', 'message': 'Invalid refresh token.'},
    );
  } on Exception {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Unable to refresh token at the moment.',
      },
    );
  }
}
