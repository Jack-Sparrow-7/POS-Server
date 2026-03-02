import 'dart:io';

import 'package:bcrypt/bcrypt.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:loxia/loxia.dart';
import 'package:pos_backend/config/env.dart';
import 'package:pos_backend/models/merchant/merchant.dart';
import 'package:pos_backend/services/jwt_service.dart';
import 'package:pos_backend/utils/db_error_matcher.dart';
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

  final result = MerchantValidators.registerSchema.tryParse(body);
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
  final businessName = result.value['businessName'] as String;
  final mobileNumber = result.value['mobileNumber'] as String;
  final email = result.value['email'] as String;
  final password = result.value['password'] as String;

  final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());

  final merchants = context.read<DataSource>().getRepository<Merchant>();

  try {
    final merchant = await merchants.save(
      MerchantPartial(
        name: name,
        businessName: businessName,
        mobileNumber: mobileNumber,
        email: email,
        passwordHash: passwordHash,
        isActive: true,
        tokenVersion: 0,
      ),
    );
    final token = JwtService.generateToken(
      userId: merchant.id,
      type: 'merchant',
      tokenVersion: merchant.tokenVersion,
    );

    final cookie = Cookie('access_token', token)
      ..httpOnly = true
      ..secure = Env.isProd
      ..path = '/'
      ..maxAge = Env.jwtExpiry.inSeconds
      ..sameSite = SameSite.lax;

    return Response.json(
      statusCode: HttpStatus.created,
      body: {
        'status': 'success',
        'token': token,
        'user': {
          'id': merchant.id,
          'name': merchant.name,
          'businessName': merchant.businessName,
          'mobileNumber': merchant.mobileNumber,
          'email': merchant.email,
          'isActive': merchant.isActive,
          'tokenVersion': merchant.tokenVersion,
          'createdAt': merchant.createdAt?.toIso8601String(),
          'updatedAt': merchant.updatedAt?.toIso8601String(),
        },
        'message': 'Merchant registered successfully.',
      },
      headers: {HttpHeaders.setCookieHeader: cookie.toString()},
    );
  } on Exception catch (e) {
    if (hasDbConstraint(e, ['merchants_email_key'])) {
      return Response.json(
        statusCode: HttpStatus.conflict,
        body: {
          'status': 'error',
          'message': 'Email already exists.',
        },
      );
    }
    if (hasDbConstraint(e, ['merchants_mobile_number_key'])) {
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
        'message': 'Unable to register merchant at the moment.',
      },
    );
  }
}
