import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:pos_server/models/counter.dart';
import 'package:pos_server/models/token_payload.dart';
import 'package:pos_server/repositories/counter_repository.dart';
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
  if (!Uuid.isValidUUID(fromString: id)) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_UUID',
      message: 'Invalid UUID format',
    );
  }

  final tokenPayload = context.read<TokenPayload>();
  final tenantId = tokenPayload.tenantId;
  final storeId = tokenPayload.storeId;

  if (tenantId == null || storeId == null) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.unauthorized,
      code: 'UNAUTHORIZED',
      message: 'Tenant or store ID is missing in token payload.',
    );
  }

  final counterRepository = CounterRepository(
    pool: context.read<Pool<String>>(),
  );

  late final Counter? counter;
  try {
    counter = await counterRepository.findByIdForStore(
      id: id,
      tenantId: tenantId,
      storeId: storeId,
    );
  } catch (_) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.internalServerError,
      code: 'COUNTER_FETCH_FAILED',
      message: 'Failed to fetch counter.',
    );
  }

  if (counter == null) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.notFound,
      code: 'COUNTER_NOT_FOUND',
      message: 'Counter not found.',
    );
  }

  return ResponseHelper.success(
    message: 'Counter fetched successfully.',
    data: {
      'counter': counter.toMap(),
    },
  );
}
