import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:pos_server/models/category.dart';
import 'package:pos_server/models/token_payload.dart';
import 'package:pos_server/repositories/category_repository.dart';
import 'package:pos_server/utils/response_helper.dart';
import 'package:pos_server/validators/category_validators.dart';
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
  final tokenPayload = context.read<TokenPayload>();
  final tenantId = tokenPayload.tenantId;

  if (tenantId == null) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.unauthorized,
      code: 'UNAUTHORIZED',
      message: 'Tenant ID is missing in token payload.',
    );
  }

  final storeId = context.request.uri.queryParameters['storeId'];
  if (storeId != null && !Uuid.isValidUUID(fromString: storeId)) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_UUID',
      message: 'Invalid UUID format',
    );
  }

  final categoryRepository = CategoryRepository(
    pool: context.read<Pool<String>>(),
  );

  late final List<Category> categories;
  try {
    categories = await categoryRepository.fetchAllForTenant(
      tenantId: tenantId,
      storeId: storeId,
    );
  } catch (_) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.internalServerError,
      code: 'CATEGORIES_FETCH_FAILED',
      message: 'Failed to fetch categories.',
    );
  }

  return ResponseHelper.success(
    message: 'Categories fetched successfully.',
    data: {
      'categories': categories.map((category) => category.toMap()).toList(),
    },
  );
}

Future<Response> _onPost(RequestContext context) async {
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

  final validationResult = CategoryValidators.createValidator.tryParse(body);
  if (!validationResult.success) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_INPUT',
      message: 'Invalid category payload.',
      details: validationResult.errors,
    );
  }

  final storeId = (validationResult.value['storeId'] as String).trim();
  final name = (validationResult.value['name'] as String).trim();
  final imageUrl = (validationResult.value['imageUrl'] as String?)?.trim();
  final sortOrder = validationResult.value['sortOrder'] as int?;

  if (!Uuid.isValidUUID(fromString: storeId)) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_UUID',
      message: 'Invalid UUID format',
    );
  }

  if (sortOrder != null && sortOrder < 0) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_INPUT',
      message: 'Invalid category payload.',
      details: {
        'sortOrder': ['Must be greater than or equal to 0'],
      },
    );
  }

  final categoryRepository = CategoryRepository(
    pool: context.read<Pool<String>>(),
  );

  late final Category? category;
  try {
    category = await categoryRepository.createForTenant(
      tenantId: tenantId,
      storeId: storeId,
      name: name,
      imageUrl: (imageUrl == null || imageUrl.isEmpty) ? null : imageUrl,
      sortOrder: sortOrder ?? 0,
    );
  } catch (e) {
    if (e.toString().contains('categories_name_store_unique')) {
      return ResponseHelper.problem(
        statusCode: HttpStatus.conflict,
        code: 'CATEGORY_NAME_EXISTS',
        message: 'Category with this name already exists in the store.',
      );
    }

    return ResponseHelper.problem(
      statusCode: HttpStatus.internalServerError,
      code: 'CATEGORY_CREATION_FAILED',
      message: 'Failed to create category.',
    );
  }

  if (category == null) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.notFound,
      code: 'STORE_NOT_FOUND',
      message: 'Store not found or not accessible.',
    );
  }

  return ResponseHelper.success(
    statusCode: HttpStatus.created,
    message: 'Category created successfully.',
    data: {
      'category': category.toMap(),
    },
  );
}
