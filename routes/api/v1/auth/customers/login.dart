import 'dart:io';

import 'package:bcrypt/bcrypt.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:loxia/loxia.dart';
import 'package:pos_backend/models/customer/customer.dart';
import 'package:pos_backend/services/jwt_service.dart';
import 'package:pos_backend/utils/auth_cookies.dart';
import 'package:pos_backend/utils/json_body_parser.dart';
import 'package:pos_backend/validators/customer_validators.dart';

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

  final result = CustomerValidators.loginSchema.tryParse(parsedBody.body!);
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

  final customers = context.read<DataSource>().getRepository<Customer>();

  try {
    final customer = await customers.findOneBy(
      where: CustomerQuery((c) => c.email.equals(email)),
    );

    if (customer == null) {
      return Response.json(
        statusCode: HttpStatus.unauthorized,
        body: {'status': 'error', 'message': 'Invalid email or password.'},
      );
    }
    if (!customer.isActive) {
      return Response.json(
        statusCode: HttpStatus.forbidden,
        body: {'status': 'error', 'message': 'Customer account is inactive.'},
      );
    }

    final isPasswordValid = BCrypt.checkpw(password, customer.passwordHash);
    if (!isPasswordValid) {
      return Response.json(
        statusCode: HttpStatus.unauthorized,
        body: {'status': 'error', 'message': 'Invalid email or password.'},
      );
    }

    final token = JwtService.generateAccessToken(
      type: 'customer',
      userId: customer.id,
      tokenVersion: customer.tokenVersion,
    );
    final refreshToken = JwtService.generateRefreshToken(
      type: 'customer',
      userId: customer.id,
      tokenVersion: customer.tokenVersion,
    );

    final setCookieHeader = buildAuthSetCookieHeaders(
      accessToken: token,
      refreshToken: refreshToken,
    );

    return Response.json(
      body: {
        'status': 'success',
        'user': {
          'id': customer.id,
          'name': customer.name,
          'mobileNumber': customer.mobileNumber,
          'email': customer.email,
          'isActive': customer.isActive,
          'tokenVersion': customer.tokenVersion,
          'createdAt': customer.createdAt?.toIso8601String(),
          'updatedAt': customer.updatedAt?.toIso8601String(),
        },
        'token': token,
        'refreshToken': refreshToken,
        'message': 'Customer logged in successfully.',
      },
      headers: {HttpHeaders.setCookieHeader: setCookieHeader},
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
