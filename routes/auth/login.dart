import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:pos_server/models/token_payload.dart';
import 'package:pos_server/repositories/internal_user_repository.dart';
import 'package:pos_server/services/auth_service.dart';
import 'package:pos_server/utils/password_helper.dart';
import 'package:pos_server/utils/response_helper.dart';
import 'package:pos_server/validators/auth_validators.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.post) {
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

  try {
    body = await context.request.json() as Map<String, dynamic>;
  } catch (e) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_JSON',
      message: 'The request body must be a valid JSON object.',
    );
  }

  final validationResult = AuthValidators.loginValidator.tryParse(body);

  if (!validationResult.success) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_INPUT',
      message: 'Invalid login payload.',
      details: validationResult.errors,
    );
  }

  final email = (validationResult.value['email'] as String).trim();
  final password = (validationResult.value['password'] as String).trim();

  final internalUserRepo = InternalUserRepository(
    pool: context.read<Pool<String>>(),
  );

  final internalUser = await internalUserRepo.findByEmail(email: email);

  if (internalUser == null) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.unauthorized,
      code: 'INVALID_CREDENTIALS',
      message: 'Invalid email or password.',
    );
  }

  if (!internalUser.isActive) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.unauthorized,
      code: 'INVALID_CREDENTIALS',
      message: 'Invalid email or password.',
    );
  }

  final isPasswordValid = PasswordHelper.verify(
    password,
    internalUser.passwordHash,
  );

  if (!isPasswordValid) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.unauthorized,
      code: 'INVALID_CREDENTIALS',
      message: 'Invalid email or password.',
    );
  }

  final tokenPayload = AuthService.generateTokens(
    TokenPayload(
      id: internalUser.id,
      role: internalUser.role,
      tenantId: internalUser.tenantId,
      storeId: internalUser.storeId,
    ),
  );

  final accessTokenCookie = AuthService.buildAccessTokenCookie(
    tokenPayload.accessToken,
  );
  final refreshTokenCookie = AuthService.buildRefreshTokenCookie(
    tokenPayload.refreshToken,
  );

  return ResponseHelper.success(
    headers: {
      HttpHeaders.setCookieHeader: [
        accessTokenCookie,
        refreshTokenCookie,
      ],
    },
    message: 'Login successful.',
    data: {
      'user': {
        'id': internalUser.id,
        'email': internalUser.email,
        'role': internalUser.role.name,
        'tenantId': internalUser.tenantId,
        'storeId': internalUser.storeId,
      },
      'accessToken': tokenPayload.accessToken,
      'refreshToken': tokenPayload.refreshToken,
    },
  );
}
