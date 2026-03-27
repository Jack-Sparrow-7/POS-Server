import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:pos_server/enums/auth_role.dart';
import 'package:pos_server/exceptions/auth_exception.dart';
import 'package:pos_server/models/token_payload.dart';
import 'package:pos_server/services/auth_service.dart';
import 'package:pos_server/utils/response_helper.dart';

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
        return ResponseHelper.problem(
          statusCode: HttpStatus.unauthorized,
          code: 'AUTH_TOKEN_MISSING',
          message:
              'You must provide a valid access token to access this resource.',
          details: {
            'path': context.request.uri.toString(),
          },
        );
      }

      try {
        final tokenPayload = AuthService.verifyAccessToken(token);

        if (allowedRoles != null && !allowedRoles.contains(tokenPayload.role)) {
          return ResponseHelper.problem(
            statusCode: HttpStatus.forbidden,
            code: 'INSUFFICIENT_PERMISSIONS',
            message: 'You do not have permission to access this resource.',
            details: {
              'path': context.request.uri.toString(),
            },
          );
        }

        return handler(
          context.provide<TokenPayload>(
            () => tokenPayload,
          ),
        );
      } on AuthException catch (error) {
        return ResponseHelper.problem(
          statusCode: HttpStatus.unauthorized,
          code: 'AUTH_TOKEN_INVALID',
          message: error.message,
          details: {
            'path': context.request.uri.toString(),
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
