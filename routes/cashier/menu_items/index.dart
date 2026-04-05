import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:pos_server/models/menu_item.dart';
import 'package:pos_server/models/token_payload.dart';
import 'package:pos_server/repositories/menu_item_repository.dart';
import 'package:pos_server/utils/response_helper.dart';
import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    .get => _onGet(context),
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
  final storeId = tokenPayload.storeId;

  if (tenantId == null || storeId == null) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.unauthorized,
      code: 'UNAUTHORIZED',
      message: 'Tenant or store ID is missing in token payload.',
    );
  }

  final isAvailableRaw = context.request.uri.queryParameters['isAvailable'];
  final categoryId = context.request.uri.queryParameters['categoryId'];
  final counterId = context.request.uri.queryParameters['counterId'];
  bool? isAvailable;

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
