import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_auth/dart_frog_auth.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:loxia/loxia.dart';
import 'package:pos_backend/models/customer/customer.dart';
import 'package:pos_backend/services/jwt_service.dart';

Future<bool> _defaultApplies(RequestContext context) async => true;

Future<Customer?> _authenticateFromToken(
  RequestContext context,
  String token,
) async {
  try {
    final payload = JwtService.verifyToken(token: token);
    final kind = payload['kind'] as String?;
    final type = payload['type'] as String?;
    final id = payload['sub'] as String?;
    final tokenVersionClaim = payload['tv'];
    final tokenVersion = switch (tokenVersionClaim) {
      final int value => value,
      final num value => value.toInt(),
      _ => null,
    };

    if (kind != null && kind != 'access') return null;
    if (type != 'customer' || id == null) return null;

    final customers = context.read<DataSource>().getRepository<Customer>();
    final customer = await customers.findOneBy(
      where: CustomerQuery((c) => c.id.equals(id)),
    );

    if (customer == null || !customer.isActive) return null;
    if (tokenVersion != null && tokenVersion != customer.tokenVersion) {
      return null;
    }

    return customer;
  } on JWTException {
    return null;
  }
}

/// Authenticates customer requests using Bearer token (mobile/desktop) or
/// cookie (web).
///
/// Supports both:
/// - [Authorization: Bearer <token>] for Flutter mobile and desktop
/// - [Cookie: access_token=<token>] for Flutter web
///
/// Use [applies] to control whether authentication runs for a request.
/// Returns 401 Unauthorized if neither credential is valid.
Middleware customerAuthMiddleware({Applies applies = _defaultApplies}) {
  return (handler) => (context) async {
    if (!await applies(context)) {
      return handler(context);
    }

    Customer? customer;

    String? bearerToken;
    final auth = context.request.headers['Authorization'];
    if (auth != null) {
      final parts = auth.split(' ');
      if (parts.length == 2 && parts[0] == 'Bearer') {
        bearerToken = parts[1];
      }
    }
    if (bearerToken != null) {
      customer = await _authenticateFromToken(context, bearerToken);
    }

    if (customer == null) {
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
          customer = await _authenticateFromToken(context, token);
        }
      }
    }

    if (customer != null) {
      return handler(context.provide<Customer>(() => customer!));
    }

    return Response.json(
      statusCode: HttpStatus.unauthorized,
      body: {'status': 'error', 'message': 'Unauthorized'},
    );
  };
}
