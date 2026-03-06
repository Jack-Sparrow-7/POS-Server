import 'dart:io';

import 'package:bcrypt/bcrypt.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:loxia/loxia.dart';
import 'package:pos_backend/models/merchant/merchant.dart';
import 'package:pos_backend/models/store/store.dart';
import 'package:pos_backend/models/terminal/terminal.dart';
import 'package:pos_backend/services/jwt_service.dart';
import 'package:pos_backend/utils/auth_cookies.dart';
import 'package:pos_backend/utils/db_error_matcher.dart';
import 'package:pos_backend/utils/generate_terminal_number.dart';
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

  final result = TerminalValidators.registerSchema.tryParse(parsedBody.body!);

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

  final name = body['name'] as String;
  final password = body['password'] as String;
  final storeId = body['storeId'] as String;

  final stores = context.read<DataSource>().getRepository<Store>();
  final merchant = context.read<Merchant>();
  final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());

  try {
    final store = await stores.findOneBy(
      where: StoreQuery(
        (s) => s.id.equals(storeId).and(s.merchantId.equals(merchant.id)),
      ),
    );
    if (store == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'status': 'error', 'message': 'Store not found.'},
      );
    }
  } on Exception {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Unable to check the store right now.',
      },
    );
  }

  final terminals = context.read<DataSource>().getRepository<Terminal>();

  const maxAttempts = 5;
  for (var attempt = 0; attempt < maxAttempts; attempt++) {
    try {
      final terminal = await terminals.save(
        TerminalPartial(
          terminalCode: generateTerminalNumber(),
          passwordHash: passwordHash,
          name: name,
          isActive: true,
          tokenVersion: 0,
          storeId: storeId,
        ),
      );
      final token = JwtService.generateAccessToken(
        userId: terminal.id,
        type: 'terminal',
        tokenVersion: terminal.tokenVersion,
      );
      final refreshToken = JwtService.generateRefreshToken(
        userId: terminal.id,
        type: 'terminal',
        tokenVersion: terminal.tokenVersion,
      );
      final setCookieHeader = buildAuthSetCookieHeaders(
        accessToken: token,
        refreshToken: refreshToken,
      );

      return Response.json(
        statusCode: HttpStatus.created,
        body: {
          'status': 'success',
          'token': token,
          'refreshToken': refreshToken,
          'user': {
            'id': terminal.id,
            'terminalCode': terminal.terminalCode,
            'name': terminal.name,
            'isActive': terminal.isActive,
            'tokenVersion': terminal.tokenVersion,
            'createdAt': terminal.createdAt?.toIso8601String(),
            'updatedAt': terminal.updatedAt?.toIso8601String(),
          },
          'message': 'Terminal created successfully.',
        },
        headers: {HttpHeaders.setCookieHeader: setCookieHeader},
      );
    } on Exception catch (e) {
      if (hasDbConstraint(e, [
        'uq_terminals_name_store_id',
      ])) {
        return Response.json(
          statusCode: HttpStatus.conflict,
          body: {
            'status': 'error',
            'message': 'Terminal name already exists for this store.',
          },
        );
      }

      if (hasDbConstraint(e, ['terminals_terminal_code_key'])) {
        if (attempt == maxAttempts - 1) {
          return Response.json(
            statusCode: HttpStatus.internalServerError,
            body: {
              'status': 'error',
              'message': 'Unable to generate a unique terminal code.',
            },
          );
        }
        continue;
      }

      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {
          'status': 'error',
          'message': 'Unable to create terminal at the moment.',
        },
      );
    }
  }
  return Response.json(
    statusCode: HttpStatus.internalServerError,
    body: {
      'status': 'error',
      'message': 'Unable to create terminal at the moment.',
    },
  );
}
