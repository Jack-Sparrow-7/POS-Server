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
    final tokenVersionClaim = payload['tv'];
    final tokenVersion = switch (tokenVersionClaim) {
      final int value => value,
      final num value => value.toInt(),
      _ => null,
    };

    if (type != 'terminal' || id == null) return null;

    final terminals = context.read<DataSource>().getRepository<Terminal>();
    final terminal = await terminals.findOneBy(
      relations: const TerminalRelations(
        store: StoreSelect(
          relations: StoreRelations(merchant: MerchantSelect()),
        ),
      ),
      where: TerminalQuery((t) => t.id.equals(id)),
    );
    if (terminal == null ||
        !terminal.isActive ||
        terminal.store == null ||
        terminal.store!.merchant == null ||
        !terminal.store!.merchant!.isActive) {
      return null;
    }
    if (tokenVersion != null && tokenVersion != terminal.tokenVersion) {
      return null;
    }

    return terminal.store!.merchant;
  } on Exception {
    return null;
  }
}

/// Authenticates terminal requests using Bearer token (mobile/desktop) or
/// cookie (web). Supports [Authorization: Bearer <token>] and
/// [Cookie: access_token=<token>]. Use [applies] to control whether
/// authentication should run for a request.
Middleware terminalAuthMiddleware({Applies applies = _defaultApplies}) {
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
