import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:pos_server/models/counter.dart';
import 'package:pos_server/models/token_payload.dart';
import 'package:pos_server/repositories/counter_repository.dart';
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
  final tenantId = tokenPayload.tenantId;
  final storeId = tokenPayload.storeId;

  if (tenantId == null || storeId == null) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.unauthorized,
      code: 'UNAUTHORIZED',
      message: 'Tenant or store ID is missing in token payload.',
    );
  }

  final isActiveRaw = context.request.uri.queryParameters['isActive'];
  bool? isActive;

  if (isActiveRaw != null) {
    final normalized = isActiveRaw.toLowerCase();
    if (normalized == 'true') {
      isActive = true;
    } else if (normalized == 'false') {
      isActive = false;
    } else {
      return ResponseHelper.problem(
        statusCode: HttpStatus.badRequest,
        code: 'INVALID_INPUT',
        message: 'Invalid counter query payload.',
        details: {
          'isActive': ['Must be a boolean value'],
        },
      );
    }
  }

  final counterRepository = CounterRepository(
    pool: context.read<Pool<String>>(),
  );

  late final List<Counter> counters;
  try {
    counters = await counterRepository.fetchAllForTenant(
      tenantId: tenantId,
      storeId: storeId,
      isActive: isActive,
    );
  } catch (_) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.internalServerError,
      code: 'COUNTERS_FETCH_FAILED',
      message: 'Failed to fetch counters.',
    );
  }

  return ResponseHelper.success(
    message: 'Counters fetched successfully.',
    data: {
      'counters': counters.map((counter) => counter.toMap()).toList(),
    },
  );
}
