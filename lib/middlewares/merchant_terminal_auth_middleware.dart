import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_auth/dart_frog_auth.dart';
import 'package:loxia/loxia.dart';
import 'package:pos_backend/models/merchant/merchant.dart';
import 'package:pos_backend/models/store/store.dart';
import 'package:pos_backend/models/terminal/terminal.dart';
import 'package:pos_backend/services/jwt_service.dart';

Future<bool> _defaultApplies(RequestContext context) async => true;

Future<Merchant?> _authenticateFromToken(
  RequestContext context,
  String token,
) async {
  try {
    final payload = JwtService.verifyToken(token: token);
    final type = payload['type'] as String?;
    final id = payload['sub'] as String?;

    if (id == null || type == null) return null;

    if (type == 'merchant') {
      final merchants = context.read<DataSource>().getRepository<Merchant>();
      return await merchants.findOneBy(
        where: MerchantQuery((m) => m.id.equals(id)),
      );
    }

    if (type == 'terminal') {
      final terminals = context.read<DataSource>().getRepository<Terminal>();
      final terminal = await terminals.findOneBy(
        relations: const TerminalRelations(
          store: StoreSelect(
            relations: StoreRelations(
              merchant: MerchantSelect(),
            ),
          ),
        ),
        where: TerminalQuery((t) => t.id.equals(id)),
      );
      return terminal?.store?.merchant;
    }

    return null;
  } on Exception {
    return null;
  }
}

/// Bearer + Cookie auth middleware for merchant or terminal JWT.
/// Supports [Authorization: Bearer <token>] (mobile/desktop) and
/// [Cookie: access_token=<token>] (web).
Middleware merchantTerminalAuthMiddleware({Applies applies = _defaultApplies}) {
  return (handler) => (context) async {
    if (!await applies(context)) {
      return handler(context);
    }

    Merchant? merchant;

    // 1. Try Bearer token first (mobile/desktop)
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

    // 2. Try cookie if Bearer didn't work (web)
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
