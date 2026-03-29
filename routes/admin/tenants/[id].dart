import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:pos_server/models/tenant.dart';
import 'package:pos_server/repositories/tenant_repository.dart';
import 'package:pos_server/utils/response_helper.dart';
import 'package:pos_server/validators/tenant_validators.dart';
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
  late final Tenant? tenant;
  if (!Uuid.isValidUUID(fromString: id)) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_UUID',
      message: 'Invalid UUID format',
    );
  }

  final pool = context.read<Pool<String>>();
  final tenantRepository = TenantRepository(pool: pool);

  try {
    tenant = await tenantRepository.findById(id);
  } catch (e) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.internalServerError,
      code: 'INTERNAL_SERVER_ERROR',
      message: 'An error occurred while fetching the tenant',
    );
  }

  if (tenant == null) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.notFound,
      code: 'TENANT_NOT_FOUND',
      message: 'Tenant not found.',
    );
  }

  return ResponseHelper.success(
    message: 'Tenant fetched successfully.',
    data: {
      'tenant': tenant.toMap(),
    },
  );
}

Future<Response> _onPatch(RequestContext context, String id) async {
  late final Map<String, dynamic> body;

  if (!Uuid.isValidUUID(fromString: id)) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_UUID',
      message: 'Invalid UUID format',
    );
  }

  try {
    body = await context.request.json() as Map<String, dynamic>;
  } catch (e) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_JSON',
      message: 'The request body must be a valid JSON object.',
    );
  }

  final validationResult = TenantValidators.updateValidator.tryParse(body);

  if (!validationResult.success) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_INPUT',
      message: 'Invalid tenant payload.',
      details: validationResult.errors,
    );
  }

  final name = validationResult.value['name'] as String?;
  final phone = validationResult.value['phone'] as String?;
  final address = (validationResult.value['address'] as String?)?.trim();
  final city = (validationResult.value['city'] as String?)?.trim();
  final state = (validationResult.value['state'] as String?)?.trim();
  final pincode = (validationResult.value['pincode'] as String?)?.trim();
  final isActive = validationResult.value['isActive'] as bool?;

  if (name == null &&
      phone == null &&
      address == null &&
      city == null &&
      state == null &&
      pincode == null &&
      isActive == null) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_INPUT',
      message: 'At least one field must be provided for update.',
    );
  }

  final pool = context.read<Pool<String>>();
  final tenantRepository = TenantRepository(pool: pool);
  late final Tenant? tenant;

  try {
    tenant = await tenantRepository.update(
      id: id,
      name: name,
      phone: phone,
      address: address,
      city: city,
      state: state,
      pincode: pincode,
      isActive: isActive,
    );
  } catch (e) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.internalServerError,
      code: 'TENANT_UPDATE_FAILED',
      message: 'Failed to update tenant.',
    );
  }

  if (tenant == null) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.notFound,
      code: 'TENANT_NOT_FOUND',
      message: 'Tenant not found.',
    );
  }

  return ResponseHelper.success(
    message: 'Tenant updated successfully.',
    data: {
      'tenant': tenant.toMap(),
    },
  );
}
