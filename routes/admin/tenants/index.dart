import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:pos_server/models/tenant.dart';
import 'package:pos_server/repositories/tenant_repository.dart';
import 'package:pos_server/utils/response_helper.dart';
import 'package:pos_server/validators/tenant_validators.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    .get => _onGet(context),
    .post => _onPost(context),
    _ => ResponseHelper.problem(
      statusCode: HttpStatus.methodNotAllowed,
      code: 'METHOD_NOT_ALLOWED',
      message: 'Method not allowed',
    ),
  };
}

Future<Response> _onGet(RequestContext context) async {
  final tenantRepository = TenantRepository(
    pool: context.read<Pool<String>>(),
  );
  List<Tenant> tenants;

  try {
    tenants = await tenantRepository.fetchAll();
  } on Exception {
    return ResponseHelper.problem(
      statusCode: HttpStatus.internalServerError,
      code: 'TENANTS_FETCH_FAILED',
      message: 'Failed to fetch tenants.',
    );
  }

  return ResponseHelper.success(
    message: 'Tenants fetched successfully.',
    data: {
      'tenants': tenants.map((tenant) => tenant.toMap()).toList(),
    },
  );
}

Future<Response> _onPost(RequestContext context) async {
  late final Map<String, dynamic> body;
  late Tenant tenant;

  try {
    body = await context.request.json() as Map<String, dynamic>;
  } catch (e) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_JSON',
      message: 'The request body must be a valid JSON object.',
    );
  }

  final validationResult = TenantValidators.createValidator.tryParse(body);

  if (!validationResult.success) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_INPUT',
      message: 'Invalid tenant payload.',
      details: validationResult.errors,
    );
  }

  final name = validationResult.value['name'] as String;
  final email = validationResult.value['email'] as String;
  final phone = validationResult.value['phone'] as String;
  final address = (validationResult.value['address'] as String?)?.trim();
  final city = (validationResult.value['city'] as String?)?.trim();
  final state = (validationResult.value['state'] as String?)?.trim();
  final pincode = (validationResult.value['pincode'] as String?)?.trim();

  final tenantRepository = TenantRepository(
    pool: context.read<Pool<String>>(),
  );

  try {
    tenant = await tenantRepository.create(
      name: name,
      email: email,
      phone: phone,
      address: (address == null || address.isEmpty) ? null : address,
      city: (city == null || city.isEmpty) ? null : city,
      state: (state == null || state.isEmpty) ? null : state,
      pincode: (pincode == null || pincode.isEmpty) ? null : pincode,
    );
  } catch (e) {
    if (e.toString().contains('tenants_email_key')) {
      return ResponseHelper.problem(
        statusCode: HttpStatus.conflict,
        code: 'TENANT_EMAIL_EXISTS',
        message: 'Tenant with this email already exists.',
      );
    }

    return ResponseHelper.problem(
      statusCode: HttpStatus.internalServerError,
      code: 'TENANT_CREATION_FAILED',
      message: 'Failed to create tenant.',
    );
  }

  return ResponseHelper.success(
    statusCode: HttpStatus.created,
    message: 'Tenant created successfully.',
    data: {
      'tenant': tenant.toMap(),
    },
  );
}
