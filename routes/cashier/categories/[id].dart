import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:pos_server/models/category.dart';
import 'package:pos_server/models/token_payload.dart';
import 'package:pos_server/repositories/category_repository.dart';
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

  final categoryRepository = CategoryRepository(
    pool: context.read<Pool<String>>(),
  );

  late final Category? category;
  try {
    category = await categoryRepository.findByIdForStore(
      id: id,
      tenantId: tenantId,
      storeId: storeId,
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
