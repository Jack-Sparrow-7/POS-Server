import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:pos_server/models/menu_item.dart';
import 'package:pos_server/models/token_payload.dart';
import 'package:pos_server/repositories/menu_item_repository.dart';
import 'package:pos_server/utils/response_helper.dart';
import 'package:pos_server/validators/menu_item_validators.dart';
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

  final query = context.request.uri.queryParameters;
  final storeId = query['storeId'];
  final categoryId = query['categoryId'];
  final counterId = query['counterId'];
  final isAvailableRaw = query['isAvailable'];

  if (storeId != null && !Uuid.isValidUUID(fromString: storeId)) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_UUID',
      message: 'Invalid UUID format',
    );
  }

  if (categoryId != null && !Uuid.isValidUUID(fromString: categoryId)) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_UUID',
      message: 'Invalid UUID format',
    );
  }

  if (counterId != null && !Uuid.isValidUUID(fromString: counterId)) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_UUID',
      message: 'Invalid UUID format',
    );
  }

  bool? isAvailable;
  if (isAvailableRaw != null) {
    final normalized = isAvailableRaw.toLowerCase();
    if (normalized == 'true') {
      isAvailable = true;
    } else if (normalized == 'false') {
      isAvailable = false;
    } else {
      return ResponseHelper.problem(
        statusCode: HttpStatus.badRequest,
        code: 'INVALID_INPUT',
        message: 'Invalid menu item query payload.',
        details: {
          'isAvailable': ['Must be a boolean value'],
        },
      );
    }
  }

  final menuItemRepository = MenuItemRepository(
    pool: context.read<Pool<String>>(),
  );

  late final List<MenuItem> menuItems;
  try {
    menuItems = await menuItemRepository.fetchAllForTenant(
      tenantId: tenantId,
      storeId: storeId,
      categoryId: categoryId,
      counterId: counterId,
      isAvailable: isAvailable,
    );
  } catch (_) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.internalServerError,
      code: 'MENU_ITEMS_FETCH_FAILED',
      message: 'Failed to fetch menu items.',
    );
  }

  return ResponseHelper.success(
    message: 'Menu items fetched successfully.',
    data: {
      'menuItems': menuItems.map((item) => item.toMap()).toList(),
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

  final validationResult = MenuItemValidators.createValidator.tryParse(body);
  if (!validationResult.success) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_INPUT',
      message: 'Invalid menu item payload.',
      details: validationResult.errors,
    );
  }

  final storeId = (validationResult.value['storeId'] as String).trim();
  final name = (validationResult.value['name'] as String).trim();
  final description = (validationResult.value['description'] as String?)
      ?.trim();
  final categoryId = (validationResult.value['categoryId'] as String?)?.trim();
  final counterId = (validationResult.value['counterId'] as String?)?.trim();
  final costPrice = validationResult.value['costPrice'] as num;
  final price = validationResult.value['price'] as num;
  final gstPercent = validationResult.value['gstPercent'] as num;
  final hsnCode = (validationResult.value['hsnCode'] as String?)?.trim();
  final isAvailable = validationResult.value['isAvailable'] as bool?;
  final stockCount = validationResult.value['stockCount'] as int?;
  final trackStock = validationResult.value['trackStock'] as bool?;
  final sortOrder = validationResult.value['sortOrder'] as int?;
  final imageUrl = (validationResult.value['imageUrl'] as String?)?.trim();

  if (!Uuid.isValidUUID(fromString: storeId)) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_UUID',
      message: 'Invalid UUID format',
    );
  }

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

  final menuItemRepository = MenuItemRepository(
    pool: context.read<Pool<String>>(),
  );

  late final MenuItem? menuItem;
  try {
    menuItem = await menuItemRepository.createForTenant(
      tenantId: tenantId,
      storeId: storeId,
      name: name,
      description: (description == null || description.isEmpty)
          ? null
          : description,
      categoryId: (categoryId == null || categoryId.isEmpty)
          ? null
          : categoryId,
      counterId: (counterId == null || counterId.isEmpty) ? null : counterId,
      costPrice: costPrice,
      price: price,
      gstPercent: gstPercent,
      hsnCode: (hsnCode == null || hsnCode.isEmpty) ? null : hsnCode,
      isAvailable: isAvailable ?? true,
      stockCount: stockCount,
      trackStock: trackStock ?? false,
      sortOrder: sortOrder ?? 0,
      imageUrl: (imageUrl == null || imageUrl.isEmpty) ? null : imageUrl,
    );
  } catch (_) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.internalServerError,
      code: 'MENU_ITEM_CREATION_FAILED',
      message: 'Failed to create menu item.',
    );
  }

  if (menuItem == null) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.notFound,
      code: 'STORE_NOT_FOUND',
      message: 'Store not found or relation is not accessible.',
    );
  }

  return ResponseHelper.success(
    statusCode: HttpStatus.created,
    message: 'Menu item created successfully.',
    data: {
      'menuItem': menuItem.toMap(),
    },
  );
}
