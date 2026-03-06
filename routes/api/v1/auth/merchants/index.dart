import 'dart:io';

import 'package:bcrypt/bcrypt.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:loxia/loxia.dart';
import 'package:pos_backend/models/merchant/merchant.dart';
import 'package:pos_backend/services/jwt_service.dart';
import 'package:pos_backend/utils/auth_cookies.dart';
import 'package:pos_backend/utils/db_error_matcher.dart';
import 'package:pos_backend/utils/json_body_parser.dart';
import 'package:pos_backend/validators/merchant_validators.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    .get => _getMerchant(context),
    .patch || .put => _updateMerchant(context),
    _ => Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {'status': 'error', 'message': 'Method not allowed.'},
    ),
  };
}

Future<Response> _getMerchant(RequestContext context) async {
  final merchant = context.read<Merchant>();

  return Response.json(
    body: {
      'status': 'success',
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
    },
  );
}

Future<Response> _updateMerchant(RequestContext context) async {
  final parsedBody = await parseJsonObjectBody(context.request);
  if (parsedBody.errorResponse != null) {
    return parsedBody.errorResponse!;
  }
  final body = parsedBody.body!;

  final result = MerchantValidators.updateSchema.tryParse(body);
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

  final name = result.value['name'] as String?;
  final businessName = result.value['businessName'] as String?;
  final mobileNumber = result.value['mobileNumber'] as String?;
  final email = result.value['email'] as String?;
  final password = result.value['password'] as String?;
  final passwordHash = password != null
      ? BCrypt.hashpw(password, BCrypt.gensalt())
      : null;
  final shouldRotateToken = passwordHash != null;

  if (name == null &&
      businessName == null &&
      mobileNumber == null &&
      email == null &&
      passwordHash == null) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {
        'status': 'error',
        'message': 'Provide at least one field to update.',
      },
    );
  }

  final merchants = context.read<DataSource>().getRepository<Merchant>();
  final merchant = context.read<Merchant>();

  try {
    final updatedMerchant = await merchants.save(
      MerchantPartial(
        id: merchant.id,
        name: name,
        businessName: businessName,
        mobileNumber: mobileNumber,
        email: email,
        passwordHash: passwordHash,
        tokenVersion: shouldRotateToken
            ? merchant.tokenVersion + 1
            : merchant.tokenVersion,
      ),
    );
    
    final headers = <String, Object>{};
    final responseBody = <String, dynamic>{
      'status': 'success',
      'user': {
        'id': updatedMerchant.id,
        'name': updatedMerchant.name,
        'businessName': updatedMerchant.businessName,
        'mobileNumber': updatedMerchant.mobileNumber,
        'email': updatedMerchant.email,
        'isActive': updatedMerchant.isActive,
        'tokenVersion': updatedMerchant.tokenVersion,
        'createdAt': updatedMerchant.createdAt?.toIso8601String(),
        'updatedAt': updatedMerchant.updatedAt?.toIso8601String(),
      },
      'message': 'Merchant updated successfully.',
    };
    if (shouldRotateToken) {
      final token = JwtService.generateAccessToken(
        userId: updatedMerchant.id,
        type: 'merchant',
        tokenVersion: updatedMerchant.tokenVersion,
      );
      final refreshToken = JwtService.generateRefreshToken(
        userId: updatedMerchant.id,
        type: 'merchant',
        tokenVersion: updatedMerchant.tokenVersion,
      );
      headers[HttpHeaders.setCookieHeader] = buildAuthSetCookieHeaders(
        accessToken: token,
        refreshToken: refreshToken,
      );
      responseBody['token'] = token;
      responseBody['refreshToken'] = refreshToken;
    }

    return Response.json(
      headers: headers,
      body: responseBody,
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
        'message': 'Unable to update merchant at the moment.',
      },
    );
  }
}
