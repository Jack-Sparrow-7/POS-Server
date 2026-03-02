import 'dart:io';

import 'package:bcrypt/bcrypt.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:loxia/loxia.dart';
import 'package:pos_backend/models/merchant/merchant.dart';
import 'package:pos_backend/models/terminal/terminal.dart';
import 'package:pos_backend/services/jwt_service.dart';
import 'package:pos_backend/utils/auth_cookies.dart';
import 'package:pos_backend/utils/db_error_matcher.dart';
import 'package:pos_backend/utils/json_body_parser.dart';
import 'package:pos_backend/validators/terminal_validators.dart';
import 'package:uuid/uuid.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return switch (context.request.method) {
    .patch || .put => _updateTerminal(context, id),
    .delete => _deleteTerminal(context, id),
    _ => Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {'status': 'error', 'message': 'Method not allowed.'},
    ),
  };
}

Future<Response> _deleteTerminal(RequestContext context, String id) async {
  if (!Uuid.isValidUUID(fromString: id)) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'status': 'error', 'message': 'Id must be a uuid value.'},
    );
  }

  final terminals = context.read<DataSource>().getRepository<Terminal>();
  final merchant = context.read<Merchant>();
  Terminal? terminal;

  try {
    terminal = await terminals.findOneBy(
      where: TerminalQuery(
        (t) => t.id.equals(id).and(t.store.merchantId.equals(merchant.id)),
      ),
    );
    if (terminal == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'status': 'error', 'message': 'Terminal not found.'},
      );
    }
  } on Exception {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Unable to verify terminal at the moment.',
      },
    );
  }

  try {
    await terminals.softDeleteEntity(terminal);

    return Response.json(
      body: {
        'status': 'success',
        'message': 'Terminal deleted successfully.',
      },
    );
  } on Exception {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Unable to delete terminal at the moment.',
      },
    );
  }
}

Future<Response> _updateTerminal(RequestContext context, String id) async {
  if (!Uuid.isValidUUID(fromString: id)) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'status': 'error', 'message': 'Id must be a uuid value.'},
    );
  }

  final parsedBody = await parseJsonObjectBody(context.request);

  if (parsedBody.errorResponse != null) {
    return parsedBody.errorResponse!;
  }

  final result = TerminalValidators.updateSchema.tryParse(parsedBody.body!);

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
  final name = body['name'] as String?;
  final password = body['password'] as String?;
  final isActive = body['isActive'] as bool?;
  final passwordHash = password == null
      ? null
      : BCrypt.hashpw(password, BCrypt.gensalt());
  final shouldRotateToken = passwordHash != null;
  final merchant = context.read<Merchant>();

  if (name == null && passwordHash == null && isActive == null) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {
        'status': 'error',
        'message': 'Request body must include at least one updatable field.',
      },
    );
  }

  final terminals = context.read<DataSource>().getRepository<Terminal>();
  Terminal? terminal;
  try {
    terminal = await terminals.findOneBy(
      where: TerminalQuery(
        (t) => t.id.equals(id).and(t.store.merchantId.equals(merchant.id)),
      ),
    );
    if (terminal == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'status': 'error', 'message': 'Terminal not found.'},
      );
    }
  } on Exception {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Unable to verify terminal at the moment.',
      },
    );
  }

  try {
    final updatedTerminal = await terminals.save(
      TerminalPartial(
        id: id,
        name: name,
        passwordHash: passwordHash,
        isActive: isActive,
        tokenVersion: shouldRotateToken
            ? terminal.tokenVersion + 1
            : terminal.tokenVersion,
      ),
    );
    final headers = <String, Object>{};
    final responseBody = <String, dynamic>{
      'status': 'success',
      'user': {
        'id': updatedTerminal.id,
        'terminalCode': updatedTerminal.terminalCode,
        'name': updatedTerminal.name,
        'isActive': updatedTerminal.isActive,
        'tokenVersion': updatedTerminal.tokenVersion,
        'createdAt': updatedTerminal.createdAt?.toIso8601String(),
        'updatedAt': updatedTerminal.updatedAt?.toIso8601String(),
      },
      'message': 'Terminal updated successfully.',
    };
    if (shouldRotateToken) {
      final token = JwtService.generateAccessToken(
        userId: updatedTerminal.id,
        type: 'terminal',
        tokenVersion: updatedTerminal.tokenVersion,
      );
      final refreshToken = JwtService.generateRefreshToken(
        userId: updatedTerminal.id,
        type: 'terminal',
        tokenVersion: updatedTerminal.tokenVersion,
      );
      headers[HttpHeaders.setCookieHeader] = buildAuthSetCookieHeaders(
        accessToken: token,
        refreshToken: refreshToken,
      );
      responseBody['token'] = token;
      responseBody['refreshToken'] = refreshToken;
    }
    return Response.json(headers: headers, body: responseBody);
  } on Exception catch (e) {
    if (hasDbConstraint(e, ['uq_terminals_name_store_id'])) {
      return Response.json(
        statusCode: HttpStatus.conflict,
        body: {
          'status': 'error',
          'message': 'Terminal name already exists for this store.',
        },
      );
    }

    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Unable to update terminal at the moment.',
      },
    );
  }
}
