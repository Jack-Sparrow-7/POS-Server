import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:pos_server/models/store.dart';
import 'package:pos_server/models/token_payload.dart';
import 'package:pos_server/repositories/store_repository.dart';
import 'package:pos_server/utils/response_helper.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    .get => _onGet(context),
    _ => ResponseHelper.problem(
      statusCode: HttpStatus.methodNotAllowed,
      code: 'METHOD_NOT_ALLOWED',
      message: 'Method not allowed',
    ),
  };
}

Future<Response> _onGet(RequestContext context) async {
  final tokenPayload = context.read<TokenPayload>();
  late final List<Store> stores;
  final storesRepo = StoreRepository(pool: context.read<Pool<String>>());

  if (tokenPayload.tenantId == null) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.unauthorized,
      code: 'UNAUTHORIZED',
      message: 'Tenant ID is missing in token payload.',
    );
  }

  try {
    stores = await storesRepo.fetchAllForTenant(tokenPayload.tenantId!);
  } catch (e) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.internalServerError,
      code: 'STORES_FETCH_FAILED',
      message: 'Failed to fetch stores.',
    );
  }

  return ResponseHelper.success(
    message: 'Stores fetched successfully.',
    data: {
      'stores': stores.map((store) => store.toMap()).toList(),
    },
  );
}
