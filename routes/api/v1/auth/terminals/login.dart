import 'dart:io';

import 'package:bcrypt/bcrypt.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:loxia/loxia.dart';
import 'package:pos_backend/config/env.dart';
import 'package:pos_backend/models/terminal/terminal.dart';
import 'package:pos_backend/services/jwt_service.dart';
import 'package:pos_backend/utils/json_body_parser.dart';
import 'package:pos_backend/validators/terminal_validators.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != .post) {
    return Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {'status': 'error', 'message': 'Method not allowed.'},
    );
  }

  final parsedBody = await parseJsonObjectBody(context.request);

  if (parsedBody.errorResponse != null) {
    return parsedBody.errorResponse!;
  }

  final result = TerminalValidators.loginSchema.tryParse(parsedBody.body!);

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

  final body = result.value;

  final password = body['password'] as String;
  final terminalCode = body['terminalCode'] as String;

  final terminals = context.read<DataSource>().getRepository<Terminal>();

  try {
    final terminal = await terminals.findOneBy(
      where: TerminalQuery((t) => t.terminalCode.equals(terminalCode)),
    );
    if (terminal == null) {
      return Response.json(
        statusCode: HttpStatus.unauthorized,
        body: {
          'status': 'error',
          'message': 'Invalid terminal code or password.',
        },
      );
    }

    final isPasswordValid = BCrypt.checkpw(password, terminal.passwordHash);

    if (!isPasswordValid) {
      return Response.json(
        statusCode: HttpStatus.unauthorized,
        body: {
          'status': 'error',
          'message': 'Invalid terminal code or password.',
        },
      );
    }

    final token = JwtService.generateToken(
      userId: terminal.id,
      type: 'terminal',
    );

    final cookie = Cookie('access_token', token)
      ..httpOnly = true
      ..secure = Env.isProd
      ..path = '/'
      ..maxAge = Env.jwtExpiry.inSeconds
      ..sameSite = SameSite.lax;

    return Response.json(
      body: {
        'status': 'success',
        'user': {
          'id': terminal.id,
          'terminalCode': terminal.terminalCode,
          'name': terminal.name,
          'createdAt': terminal.createdAt?.toIso8601String(),
          'updatedAt': terminal.createdAt?.toIso8601String(),
        },
        'token': token,
        'message': 'Terminal logged in successfully.',
      },
      headers: {HttpHeaders.setCookieHeader: cookie.toString()},
    );
  } on Exception {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Unable to process login at the moment.',
      },
    );
  }
}
