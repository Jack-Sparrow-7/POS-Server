import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:pos_server/models/store.dart';
import 'package:pos_server/models/token_payload.dart';
import 'package:pos_server/repositories/store_repository.dart';
import 'package:pos_server/utils/response_helper.dart';
import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';

Future<Response> onRequest(
  RequestContext context,
  String id,
) async {
  return switch (context.request.method) {
    .get => _onGet(context, id),
    _ => ResponseHelper.problem(
      statusCode: HttpStatus.methodNotAllowed,
      code: 'METHOD_NOT_ALLOWED',
      message: 'Method not allowed',
    ),
  };
}

Future<Response> _onGet(RequestContext context, String id) async {
  final tokenPayload = context.read<TokenPayload>();
  late final Store? store;
  final storeRepo = StoreRepository(pool: context.read<Pool<String>>());

  if (!Uuid.isValidUUID(fromString: id)) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_UUID',
      message: 'Invalid store ID format.',
    );
  }

  if (tokenPayload.tenantId == null) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.unauthorized,
      code: 'UNAUTHORIZED',
      message: 'Tenant ID is missing in token payload.',
    );
  }

  try {
    store = await storeRepo.findByIdForTenant(
      id: id,
      tenantId: tokenPayload.tenantId!,
    );
  } catch (e) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.internalServerError,
      code: 'STORE_FETCH_FAILED',
      message: 'Failed to fetch store.',
    );
  }

  if (store == null) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.notFound,
      code: 'STORE_NOT_FOUND',
      message: 'Store not found.',
    );
  }

  return ResponseHelper.success(
    message: 'Store details fetched successfully.',
    data: {
      'store': store.toMap(),
    },
  );
}
