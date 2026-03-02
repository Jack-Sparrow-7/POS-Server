import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_auth/dart_frog_auth.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:loxia/loxia.dart';
import 'package:pos_backend/models/merchant/merchant.dart';
import 'package:pos_backend/services/jwt_service.dart';

Future<Merchant?> _authenticateFromToken(
  RequestContext context,
  String token,
) async {
  try {
    final payload = JwtService.verifyToken(token: token);
    final type = payload['type'] as String?;
    final id = payload['sub'] as String?;
    if (type != 'merchant' || id == null) return null;

    final merchants = context.read<DataSource>().getRepository<Merchant>();
    return await merchants.findOneBy(
      where: MerchantQuery((m) => m.id.equals(id)),
    );
  } on JWTException {
    return null;
  }
}

/// Authenticates merchant requests using Bearer token (mobile/desktop) or
/// cookie (web).
///
/// Supports both:
/// - [Authorization: Bearer <token>] for Flutter mobile and desktop
/// - [Cookie: access_token=<token>] for Flutter web
///
/// Use [applies] to control whether authentication runs for a request.
/// Returns 401 Unauthorized if neither credential is valid.
Middleware merchantAuthMiddleware({Applies applies = _defaultApplies}) {
  return (handler) => (context) async {
    if (!await applies(context)) {
      return handler(context);
    }

    Merchant? merchant;

    String? bearerToken;
    final auth = context.request.headers['Authorization'];
    if (auth != null) {
      final parts = auth.split(' ');
      if (parts.length == 2 && parts[0] == 'Bearer') {
        bearerToken = parts[1];
      }
    }
    if (bearerToken != null) {
      merchant = await _authenticateFromToken(context, bearerToken);
    }

    if (merchant == null) {
      final cookieString = context.request.headers['Cookie'];
      if (cookieString != null) {
        final cookies = <String, String>{};
        for (final cookie in cookieString.split('; ')) {
          final parts = cookie.split('=');
          if (parts.length == 2) {
            cookies[parts[0].trim()] = parts[1].trim();
          }
        }
        final token = cookies['access_token'];
        if (token != null) {
          merchant = await _authenticateFromToken(context, token);
        }
      }
    }

    if (merchant != null) {
      return handler(context.provide<Merchant>(() => merchant!));
    }

    return Response.json(
      statusCode: HttpStatus.unauthorized,
      body: {'status': 'error', 'message': 'Unauthorized'},
    );
  };
}

Future<bool> _defaultApplies(RequestContext context) async => true;
