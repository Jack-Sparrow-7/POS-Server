import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:pos_server/models/store.dart';
import 'package:pos_server/repositories/store_repository.dart';
import 'package:pos_server/utils/response_helper.dart';
import 'package:pos_server/validators/store_validators.dart';
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

  final storeRepository = StoreRepository(
    pool: context.read<Pool<String>>(),
  );
  late final Store? store;

  try {
    store = await storeRepository.findByIdForAdmin(id);
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
    message: 'Store fetched successfully.',
    data: {
      'store': store.toMap(),
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

  late final Map<String, dynamic> body;

  try {
    body = await context.request.json() as Map<String, dynamic>;
  } catch (e) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_JSON',
      message: 'The request body must be a valid JSON object.',
    );
  }

  final validationResult = StoreValidators.updateValidator.tryParse(body);

  if (!validationResult.success) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_INPUT',
      message: 'Invalid store payload.',
      details: validationResult.errors,
    );
  }

  final subscriptionStatus =
      (validationResult.value['subscriptionStatus'] as String?)?.trim();
  final subscriptionStartedAtRaw =
      validationResult.value['subscriptionStartedAt'] as String?;
  final subscriptionExpiresAtRaw =
      validationResult.value['subscriptionExpiresAt'] as String?;
  final trialExpiresAtRaw = validationResult.value['trialExpiresAt'] as String?;
  final phonepeClientId = (validationResult.value['phonepeClientId'] as String?)
      ?.trim();
  final phonepeClientVersion =
      validationResult.value['phonepeClientVersion'] as int?;
  final phonepeClientSecret =
      (validationResult.value['phonepeClientSecret'] as String?)?.trim();
  final phonepeConfigured =
      validationResult.value['phonepeConfigured'] as bool?;
  final gstEnabled = validationResult.value['gstEnabled'] as bool?;
  final isOpen = validationResult.value['isOpen'] as bool?;
  final isActive = validationResult.value['isActive'] as bool?;

  if (subscriptionStatus != null &&
      !const {'trial', 'active', 'expired', 'suspended'}.contains(
        subscriptionStatus,
      )) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_INPUT',
      message: 'Invalid store payload.',
      details: {
        'subscriptionStatus': [
          'Must be one of: trial, active, expired, suspended',
        ],
      },
    );
  }

  if (phonepeClientVersion != null && phonepeClientVersion < 1) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_INPUT',
      message: 'Invalid store payload.',
      details: {
        'phonepeClientVersion': ['Must be greater than or equal to 1'],
      },
    );
  }

  DateTime? parseDateTime(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    try {
      return DateTime.parse(value);
    } catch (_) {
      throw FormatException(field);
    }
  }

  late final DateTime? subscriptionStartedAt;
  late final DateTime? subscriptionExpiresAt;
  late final DateTime? trialExpiresAt;

  try {
    subscriptionStartedAt = parseDateTime(
      subscriptionStartedAtRaw,
      'subscriptionStartedAt',
    );
    subscriptionExpiresAt = parseDateTime(
      subscriptionExpiresAtRaw,
      'subscriptionExpiresAt',
    );
    trialExpiresAt = parseDateTime(trialExpiresAtRaw, 'trialExpiresAt');
  } on FormatException catch (e) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_INPUT',
      message: 'Invalid store payload.',
      details: {
        e.message: ['Must be a valid ISO-8601 datetime string'],
      },
    );
  }

  if (subscriptionStatus == null &&
      subscriptionStartedAtRaw == null &&
      subscriptionExpiresAtRaw == null &&
      trialExpiresAtRaw == null &&
      phonepeClientId == null &&
      phonepeClientVersion == null &&
      phonepeClientSecret == null &&
      phonepeConfigured == null &&
      gstEnabled == null &&
      isOpen == null &&
      isActive == null) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_INPUT',
      message: 'At least one field must be provided for update.',
    );
  }

  final storeRepository = StoreRepository(
    pool: context.read<Pool<String>>(),
  );
  late final Store? store;

  try {
    store = await storeRepository.updateForAdmin(
      id: id,
      subscriptionStatus: subscriptionStatus,
      subscriptionStartedAt: subscriptionStartedAt,
      subscriptionExpiresAt: subscriptionExpiresAt,
      trialExpiresAt: trialExpiresAt,
      phonepeClientId: (phonepeClientId == null || phonepeClientId.isEmpty)
          ? null
          : phonepeClientId,
      phonepeClientVersion: phonepeClientVersion,
      phonepeClientSecret:
          (phonepeClientSecret == null || phonepeClientSecret.isEmpty)
          ? null
          : phonepeClientSecret,
      phonepeConfigured: phonepeConfigured,
      gstEnabled: gstEnabled,
      isOpen: isOpen,
      isActive: isActive,
    );
  } catch (e) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.internalServerError,
      code: 'STORE_UPDATE_FAILED',
      message: 'Failed to update store.',
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
    message: 'Store updated successfully.',
    data: {
      'store': store.toMap(),
    },
  );
}
