import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:pos_server/models/counter.dart';
import 'package:pos_server/models/token_payload.dart';
import 'package:pos_server/repositories/counter_repository.dart';
import 'package:pos_server/utils/response_helper.dart';
import 'package:pos_server/validators/counter_validators.dart';
import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';

Future<Response> onRequest(
  RequestContext context,
  String id,
) async {
  return switch (context.request.method) {
    .get => _onGet(context, id),
    .patch => _onPatch(context, id),
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
  if (tenantId == null) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.unauthorized,
      code: 'UNAUTHORIZED',
      message: 'Tenant ID is missing in token payload.',
    );
  }

  final counterRepository = CounterRepository(
    pool: context.read<Pool<String>>(),
  );

  late final Counter? counter;
  try {
    counter = await counterRepository.findByIdForTenant(
      id: id,
      tenantId: tenantId,
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

Future<Response> _onPatch(RequestContext context, String id) async {
  if (!Uuid.isValidUUID(fromString: id)) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_UUID',
      message: 'Invalid UUID format',
    );
  }

  final tokenPayload = context.read<TokenPayload>();
  final tenantId = tokenPayload.tenantId;
  if (tenantId == null) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.unauthorized,
      code: 'UNAUTHORIZED',
      message: 'Tenant ID is missing in token payload.',
    );
  }

  late final Map<String, dynamic> body;
  try {
    body = await context.request.json() as Map<String, dynamic>;
  } catch (_) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_JSON',
      message: 'The request body must be a valid JSON object.',
    );
  }

  final validationResult = CounterValidators.updateValidator.tryParse(body);
  if (!validationResult.success) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_INPUT',
      message: 'Invalid counter payload.',
      details: validationResult.errors,
    );
  }

  final name = (validationResult.value['name'] as String?)?.trim();
  final description = (validationResult.value['description'] as String?)
      ?.trim();
  final sortOrder = validationResult.value['sortOrder'] as int?;
  final isActive = validationResult.value['isActive'] as bool?;
  final descriptionProvided = body.containsKey('description');

  if (sortOrder != null && sortOrder < 0) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_INPUT',
      message: 'Invalid counter payload.',
      details: {
        'sortOrder': ['Must be greater than or equal to 0'],
      },
    );
  }

  if (name == null &&
      !descriptionProvided &&
      sortOrder == null &&
      isActive == null) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_INPUT',
      message: 'At least one field must be provided for update.',
    );
  }

  final counterRepository = CounterRepository(
    pool: context.read<Pool<String>>(),
  );

  late final Counter? counter;
  try {
    counter = await counterRepository.updateForTenant(
      id: id,
      tenantId: tenantId,
      name: name,
      description: descriptionProvided
          ? ((description == null || description.isEmpty) ? null : description)
          : null,
      descriptionProvided: descriptionProvided,
      sortOrder: sortOrder,
      isActive: isActive,
    );
  } catch (e) {
    if (e.toString().contains('counters_name_store_unique')) {
      return ResponseHelper.problem(
        statusCode: HttpStatus.conflict,
        code: 'COUNTER_NAME_EXISTS',
        message: 'Counter with this name already exists in the store.',
      );
    }

    return ResponseHelper.problem(
      statusCode: HttpStatus.internalServerError,
      code: 'COUNTER_UPDATE_FAILED',
      message: 'Failed to update counter.',
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
    message: 'Counter updated successfully.',
    data: {
      'counter': counter.toMap(),
    },
  );
}
