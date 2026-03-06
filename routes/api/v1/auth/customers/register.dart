import 'dart:io';

import 'package:bcrypt/bcrypt.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:loxia/loxia.dart';
import 'package:pos_backend/models/customer/customer.dart';
import 'package:pos_backend/services/jwt_service.dart';
import 'package:pos_backend/utils/auth_cookies.dart';
import 'package:pos_backend/utils/db_error_matcher.dart';
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

  final result = CustomerValidators.registerSchema.tryParse(parsedBody.body!);
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

  final name = result.value['name'] as String;
  final mobileNumber = result.value['mobileNumber'] as String;
  final email = result.value['email'] as String;
  final password = result.value['password'] as String;

  final customers = context.read<DataSource>().getRepository<Customer>();

  try {
    final customer = await customers.save(
      CustomerPartial(
        name: name,
        mobileNumber: mobileNumber,
        email: email,
        passwordHash: BCrypt.hashpw(password, BCrypt.gensalt()),
        isActive: true,
        tokenVersion: 0,
      ),
    );

    final token = JwtService.generateAccessToken(
      userId: customer.id,
      type: 'customer',
      tokenVersion: customer.tokenVersion,
    );
    final refreshToken = JwtService.generateRefreshToken(
      userId: customer.id,
      type: 'customer',
      tokenVersion: customer.tokenVersion,
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
          'id': customer.id,
          'name': customer.name,
          'mobileNumber': customer.mobileNumber,
          'email': customer.email,
          'isActive': customer.isActive,
          'tokenVersion': customer.tokenVersion,
          'createdAt': customer.createdAt?.toIso8601String(),
          'updatedAt': customer.updatedAt?.toIso8601String(),
        },
        'message': 'Customer registered successfully.',
      },
      headers: {HttpHeaders.setCookieHeader: setCookieHeader},
    );
  } on Exception catch (e) {
    if (hasDbConstraint(e, ['customers_email_key'])) {
      return Response.json(
        statusCode: HttpStatus.conflict,
        body: {
          'status': 'error',
          'message': 'Email already exists.',
        },
      );
    }
    if (hasDbConstraint(e, ['customers_mobile_number_key'])) {
      return Response.json(
        statusCode: HttpStatus.conflict,
        body: {
          'status': 'error',
          'message': 'Mobile number already exists.',
        },
      );
    }

    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Unable to register customer at the moment.',
      },
    );
  }
}
