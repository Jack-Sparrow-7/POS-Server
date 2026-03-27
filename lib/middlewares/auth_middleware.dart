import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:pos_server/enums/auth_role.dart';
import 'package:pos_server/exceptions/auth_exception.dart';
import 'package:pos_server/models/token_payload.dart';
import 'package:pos_server/services/auth_service.dart';

/// Verifies the incoming access token and adds its payload to the
/// request context.
Middleware authMiddleware({List<AuthRole>? allowedRoles}) =>
    (Handler handler) => (context) async {
      final authorization = context.request.headers['Authorization'];
      final bearerToken = AuthService.extractBearerToken(authorization);
      final cookieToken = AuthService.extractAccessTokenFromCookies(
        context.request.headers[HttpHeaders.cookieHeader],
      );
      final token = bearerToken ?? cookieToken;

      if (token == null) {
        return Response.json(
          statusCode: HttpStatus.unauthorized,
          body: {
            'status': 'error',
            'error': {
              'code': 'AUTH_TOKEN_MISSING',
              'message': 'Authentication token not found.',
            },
          },
        );
      }

      try {
        final tokenPayload = AuthService.verifyAccessToken(token);

        if (allowedRoles != null && !allowedRoles.contains(tokenPayload.role)) {
          return Response.json(
            statusCode: HttpStatus.forbidden,
            body: {
              'status': 'error',
              'error': {
                'code': 'INSUFFICIENT_PERMISSIONS',
                'message':
                    'You do not have the required role to access '
                    'this resource.',
              },
            },
          );
        }

        return handler(
          context.provide<TokenPayload>(
            () => tokenPayload,
          ),
        );
      } on AuthException catch (error) {
        return Response.json(
          statusCode: HttpStatus.unauthorized,
          body: {
            'status': 'error',
            'error': {
              'code': 'AUTH_TOKEN_INVALID',
              'message': error.message,
            },
          },
        );
      }
    };

/// Restricts access to authenticated super administrators only.
Middleware superAdminOnly() => authMiddleware(allowedRoles: [.superAdmin]);

/// Restricts access to authenticated merchants only.
Middleware merchantOnly() => authMiddleware(allowedRoles: [.merchant]);

/// Restricts access to authenticated cashiers only.
Middleware cashierOnly() => authMiddleware(allowedRoles: [.cashier]);

/// Restricts access to authenticated merchants or cashiers.
Middleware merchantOrCashier() =>
    authMiddleware(allowedRoles: [.merchant, .cashier]);

/// Restricts access to authenticated customers only.
Middleware customerOnly() => authMiddleware(allowedRoles: [.customer]);

/// Requires a valid authenticated user regardless of role.
Middleware anyAuthenticated() => authMiddleware();
