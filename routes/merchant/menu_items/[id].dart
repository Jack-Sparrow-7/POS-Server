import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:pos_server/models/menu_item.dart';
import 'package:pos_server/models/token_payload.dart';
import 'package:pos_server/repositories/menu_item_repository.dart';
import 'package:pos_server/utils/response_helper.dart';
import 'package:pos_server/validators/menu_item_validators.dart';
import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';

Future<Response> onRequest(
  RequestContext context,
  String id,
) async {
  return switch (context.request.method) {
    .get => _onGet(context, id),
    .patch => _onPatch(context, id),
    .delete => _onDelete(context, id),
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

  final menuItemRepository = MenuItemRepository(
    pool: context.read<Pool<String>>(),
  );

  late final MenuItem? menuItem;
  try {
    menuItem = await menuItemRepository.findByIdForTenant(
      id: id,
      tenantId: tenantId,
    );
  } catch (_) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.internalServerError,
      code: 'MENU_ITEM_FETCH_FAILED',
      message: 'Failed to fetch menu item.',
    );
  }

  if (menuItem == null) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.notFound,
      code: 'MENU_ITEM_NOT_FOUND',
      message: 'Menu item not found.',
    );
  }

  return ResponseHelper.success(
    message: 'Menu item fetched successfully.',
    data: {
      'menuItem': menuItem.toMap(),
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

  final validationResult = MenuItemValidators.updateValidator.tryParse(body);
  if (!validationResult.success) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_INPUT',
      message: 'Invalid menu item payload.',
      details: validationResult.errors,
    );
  }

  final name = (validationResult.value['name'] as String?)?.trim();
  final description = (validationResult.value['description'] as String?)
      ?.trim();
  final categoryId = (validationResult.value['categoryId'] as String?)?.trim();
  final counterId = (validationResult.value['counterId'] as String?)?.trim();
  final costPrice = validationResult.value['costPrice'] as num?;
  final price = validationResult.value['price'] as num?;
  final gstPercent = validationResult.value['gstPercent'] as num?;
  final hsnCode = (validationResult.value['hsnCode'] as String?)?.trim();
  final isAvailable = validationResult.value['isAvailable'] as bool?;
  final stockCount = validationResult.value['stockCount'] as int?;
  final trackStock = validationResult.value['trackStock'] as bool?;
  final sortOrder = validationResult.value['sortOrder'] as int?;
  final imageUrl = (validationResult.value['imageUrl'] as String?)?.trim();

  final descriptionProvided = body.containsKey('description');
  final categoryIdProvided = body.containsKey('categoryId');
  final counterIdProvided = body.containsKey('counterId');
  final hsnCodeProvided = body.containsKey('hsnCode');
  final stockCountProvided = body.containsKey('stockCount');
  final imageUrlProvided = body.containsKey('imageUrl');

  if (categoryId != null &&
      categoryId.isNotEmpty &&
      !Uuid.isValidUUID(fromString: categoryId)) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_UUID',
      message: 'Invalid UUID format',
    );
  }

  if (counterId != null &&
      counterId.isNotEmpty &&
      !Uuid.isValidUUID(fromString: counterId)) {
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
      message: 'Invalid menu item payload.',
      details: {
        'sortOrder': ['Must be greater than or equal to 0'],
      },
    );
  }

  if (stockCount != null && stockCount < 0) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_INPUT',
      message: 'Invalid menu item payload.',
      details: {
        'stockCount': ['Must be greater than or equal to 0'],
      },
    );
  }

  if (name == null &&
      !descriptionProvided &&
      !categoryIdProvided &&
      !counterIdProvided &&
      costPrice == null &&
      price == null &&
      gstPercent == null &&
      !hsnCodeProvided &&
      isAvailable == null &&
      !stockCountProvided &&
      trackStock == null &&
      sortOrder == null &&
      !imageUrlProvided) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_INPUT',
      message: 'At least one field must be provided for update.',
    );
  }

  final menuItemRepository = MenuItemRepository(
    pool: context.read<Pool<String>>(),
  );

  late final MenuItem? menuItem;
  try {
    menuItem = await menuItemRepository.updateForTenant(
      id: id,
      tenantId: tenantId,
      name: name,
      description: descriptionProvided
          ? ((description == null || description.isEmpty) ? null : description)
          : null,
      descriptionProvided: descriptionProvided,
      categoryId: categoryIdProvided
          ? ((categoryId == null || categoryId.isEmpty) ? null : categoryId)
          : null,
      categoryIdProvided: categoryIdProvided,
      counterId: counterIdProvided
          ? ((counterId == null || counterId.isEmpty) ? null : counterId)
          : null,
      counterIdProvided: counterIdProvided,
      costPrice: costPrice,
      price: price,
      gstPercent: gstPercent,
      hsnCode: hsnCodeProvided
          ? ((hsnCode == null || hsnCode.isEmpty) ? null : hsnCode)
          : null,
      hsnCodeProvided: hsnCodeProvided,
      isAvailable: isAvailable,
      stockCount: stockCount,
      stockCountProvided: stockCountProvided,
      trackStock: trackStock,
      sortOrder: sortOrder,
      imageUrl: imageUrlProvided
          ? ((imageUrl == null || imageUrl.isEmpty) ? null : imageUrl)
          : null,
      imageUrlProvided: imageUrlProvided,
    );
  } catch (_) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.internalServerError,
      code: 'MENU_ITEM_UPDATE_FAILED',
      message: 'Failed to update menu item.',
    );
  }

  if (menuItem == null) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.notFound,
      code: 'MENU_ITEM_NOT_FOUND',
      message: 'Menu item not found.',
    );
  }

  return ResponseHelper.success(
    message: 'Menu item updated successfully.',
    data: {
      'menuItem': menuItem.toMap(),
    },
  );
}

Future<Response> _onDelete(RequestContext context, String id) async {
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

  final menuItemRepository = MenuItemRepository(
    pool: context.read<Pool<String>>(),
  );

  late final bool deleted;
  try {
    deleted = await menuItemRepository.deleteByIdForTenant(
      id: id,
      tenantId: tenantId,
    );
  } catch (_) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.internalServerError,
      code: 'MENU_ITEM_DELETE_FAILED',
      message: 'Failed to delete menu item.',
    );
  }

  if (!deleted) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.notFound,
      code: 'MENU_ITEM_NOT_FOUND',
      message: 'Menu item not found.',
    );
  }

  return ResponseHelper.success(
    message: 'Menu item deleted successfully.',
  );
}
