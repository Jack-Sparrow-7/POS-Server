import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:pos_server/models/store.dart';
import 'package:pos_server/repositories/store_repository.dart';
import 'package:pos_server/utils/response_helper.dart';
import 'package:pos_server/validators/store_validators.dart';
import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';

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
  final storeRepository = StoreRepository(
    pool: context.read<Pool<String>>(),
  );
  List<Store> stores;

  try {
    stores = await storeRepository.fetchAllForAdmin();
  } on Exception {
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

Future<Response> _onPost(RequestContext context) async {
  late final Map<String, dynamic> body;
  late final Store store;

  try {
    body = await context.request.json() as Map<String, dynamic>;
  } catch (e) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_JSON',
      message: 'The request body must be a valid JSON object.',
    );
  }

  final validationResult = StoreValidators.createValidator.tryParse(body);

  if (!validationResult.success) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_INPUT',
      message: 'Invalid store payload.',
      details: validationResult.errors,
    );
  }

  final tenantId = (validationResult.value['tenantId'] as String).trim();
  final name = (validationResult.value['name'] as String).trim();
  final slug = (validationResult.value['slug'] as String).trim();
  final description = (validationResult.value['description'] as String?)
      ?.trim();
  final address = (validationResult.value['address'] as String?)?.trim();
  final city = (validationResult.value['city'] as String?)?.trim();
  final state = (validationResult.value['state'] as String?)?.trim();
  final pincode = (validationResult.value['pincode'] as String?)?.trim();
  final phone = (validationResult.value['phone'] as String?)?.trim();
  final gstin = (validationResult.value['gstin'] as String?)?.trim();

  if (!Uuid.isValidUUID(fromString: tenantId)) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_UUID',
      message: 'Invalid UUID format',
    );
  }

  final storeRepository = StoreRepository(
    pool: context.read<Pool<String>>(),
  );

  try {
    store = await storeRepository.create(
      tenantId: tenantId,
      name: name,
      slug: slug,
      description: (description == null || description.isEmpty)
          ? null
          : description,
      address: (address == null || address.isEmpty) ? null : address,
      city: (city == null || city.isEmpty) ? null : city,
      state: (state == null || state.isEmpty) ? null : state,
      pincode: (pincode == null || pincode.isEmpty) ? null : pincode,
      phone: (phone == null || phone.isEmpty) ? null : phone,
      gstin: (gstin == null || gstin.isEmpty) ? null : gstin,
    );
  } catch (e) {
    if (e.toString().contains('stores_slug_key')) {
      return ResponseHelper.problem(
        statusCode: HttpStatus.conflict,
        code: 'STORE_SLUG_EXISTS',
        message: 'Store with this slug already exists.',
      );
    }

    if (e.toString().contains('stores_tenant_id_fkey')) {
      return ResponseHelper.problem(
        statusCode: HttpStatus.badRequest,
        code: 'TENANT_NOT_FOUND',
        message: 'Tenant not found for provided tenantId.',
      );
    }

    return ResponseHelper.problem(
      statusCode: HttpStatus.internalServerError,
      code: 'STORE_CREATION_FAILED',
      message: 'Failed to create store.',
    );
  }

  return ResponseHelper.success(
    statusCode: HttpStatus.created,
    message: 'Store created successfully.',
    data: {
      'store': store.toMap(),
    },
  );
}
