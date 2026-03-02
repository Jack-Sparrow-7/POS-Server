import 'dart:io';

import 'package:bcrypt/bcrypt.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:loxia/loxia.dart';
import 'package:pos_backend/config/env.dart';
import 'package:pos_backend/models/merchant/merchant.dart';
import 'package:pos_backend/services/jwt_service.dart';
import 'package:pos_backend/utils/json_body_parser.dart';
import 'package:pos_backend/validators/merchant_validators.dart';

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

  final body = parsedBody.body!;

  final result = MerchantValidators.loginSchema.tryParse(body);

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

  final email = result.value['email'] as String;
  final password = result.value['password'] as String;

  final merchants = context.read<DataSource>().getRepository<Merchant>();

  try {
    final merchant = await merchants.findOneBy(
      where: MerchantQuery((m) => m.email.equals(email)),
    );
    if (merchant == null) {
      return Response.json(
        statusCode: HttpStatus.unauthorized,
        body: {'status': 'error', 'message': 'Invalid email or password.'},
      );
    }

    final isPasswordValid = BCrypt.checkpw(password, merchant.passwordHash);

    if (!isPasswordValid) {
      return Response.json(
        statusCode: HttpStatus.unauthorized,
        body: {'status': 'error', 'message': 'Invalid email or password.'},
      );
    }

    final token = JwtService.generateToken(
      type: 'merchant',
      userId: merchant.id,
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
          'id': merchant.id,
          'name': merchant.name,
          'businessName': merchant.businessName,
          'mobileNumber': merchant.mobileNumber,
          'email': merchant.email,
          'createdAt': merchant.createdAt?.toIso8601String(),
          'updatedAt': merchant.updatedAt?.toIso8601String(),
        },
        'token': token,
        'message': 'Merchant logged in successfully.',
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
