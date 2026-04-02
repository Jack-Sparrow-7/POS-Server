import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:pos_server/models/category.dart';
import 'package:pos_server/models/token_payload.dart';
import 'package:pos_server/repositories/category_repository.dart';
import 'package:pos_server/utils/response_helper.dart';
import 'package:pos_server/validators/category_validators.dart';
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

  final categoryRepository = CategoryRepository(
    pool: context.read<Pool<String>>(),
  );

  late final Category? category;
  try {
    category = await categoryRepository.findByIdForTenant(
      id: id,
      tenantId: tenantId,
    );
  } catch (_) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.internalServerError,
      code: 'CATEGORY_FETCH_FAILED',
      message: 'Failed to fetch category.',
    );
  }

  if (category == null) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.notFound,
      code: 'CATEGORY_NOT_FOUND',
      message: 'Category not found.',
    );
  }

  return ResponseHelper.success(
    message: 'Category fetched successfully.',
    data: {
      'category': category.toMap(),
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

  final validationResult = CategoryValidators.updateValidator.tryParse(body);
  if (!validationResult.success) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_INPUT',
      message: 'Invalid category payload.',
      details: validationResult.errors,
    );
  }

  final name = (validationResult.value['name'] as String?)?.trim();
  final imageUrl = (validationResult.value['imageUrl'] as String?)?.trim();
  final sortOrder = validationResult.value['sortOrder'] as int?;
  final isActive = validationResult.value['isActive'] as bool?;
  final imageUrlProvided = body.containsKey('imageUrl');

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

  if (name == null &&
      !imageUrlProvided &&
      sortOrder == null &&
      isActive == null) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_INPUT',
      message: 'At least one field must be provided for update.',
    );
  }

  final categoryRepository = CategoryRepository(
    pool: context.read<Pool<String>>(),
  );

  late final Category? category;
  try {
    category = await categoryRepository.updateForTenant(
      id: id,
      tenantId: tenantId,
      name: name,
      imageUrl: imageUrlProvided
          ? ((imageUrl == null || imageUrl.isEmpty) ? null : imageUrl)
          : null,
      imageUrlProvided: imageUrlProvided,
      sortOrder: sortOrder,
      isActive: isActive,
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
      code: 'CATEGORY_UPDATE_FAILED',
      message: 'Failed to update category.',
    );
  }

  if (category == null) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.notFound,
      code: 'CATEGORY_NOT_FOUND',
      message: 'Category not found.',
    );
  }

  return ResponseHelper.success(
    message: 'Category updated successfully.',
    data: {
      'category': category.toMap(),
    },
  );
}
