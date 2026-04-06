import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:pos_server/models/token_payload.dart';
import 'package:pos_server/repositories/order_repository.dart';
import 'package:pos_server/utils/response_helper.dart';
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
  final storeId = tokenPayload.storeId;

  if (tenantId == null || storeId == null) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.forbidden,
      code: 'FORBIDDEN',
      message: 'Cashier is not scoped to a store.',
    );
  }

  final status = context.request.uri.queryParameters['status'];
  final fromDateRaw = context.request.uri.queryParameters['fromDate'];
  final toDateRaw = context.request.uri.queryParameters['toDate'];

  const allowedStatuses = <String>{
    'pending',
    'confirmed',
    'ready',
    'completed',
    'cancelled',
  };

  if (status != null && !allowedStatuses.contains(status)) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_INPUT',
      message: 'Invalid orders query payload.',
      details: {
        'status': ['Unsupported status filter.'],
      },
    );
  }

  DateTime? fromDate;
  DateTime? toDate;

  if (fromDateRaw != null) {
    fromDate = DateTime.tryParse(fromDateRaw);
    if (fromDate == null) {
      return ResponseHelper.problem(
        statusCode: HttpStatus.badRequest,
        code: 'INVALID_INPUT',
        message: 'Invalid orders query payload.',
        details: {
          'fromDate': ['Invalid date format.'],
        },
      );
    }
  }

  if (toDateRaw != null) {
    toDate = DateTime.tryParse(toDateRaw);
    if (toDate == null) {
      return ResponseHelper.problem(
        statusCode: HttpStatus.badRequest,
        code: 'INVALID_INPUT',
        message: 'Invalid orders query payload.',
        details: {
          'toDate': ['Invalid date format.'],
        },
      );
    }
  }

  if (fromDate != null && toDate != null && fromDate.isAfter(toDate)) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_INPUT',
      message: 'Invalid orders query payload.',
      details: {
        'fromDate': ['Must be <= toDate.'],
      },
    );
  }

  final repository = OrderRepository(
    pool: context.read<Pool<String>>(),
  );

  try {
    final orders = await repository.fetchAllForCashierStore(
      tenantId: tenantId,
      storeId: storeId,
      status: status,
      fromDate: fromDate,
      toDate: toDate,
    );

    return ResponseHelper.success(
      data: {'orders': orders},
      message: 'Orders fetched successfully.',
    );
  } catch (_) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.internalServerError,
      code: 'ORDERS_FETCH_FAILED',
      message: 'Failed to fetch orders.',
    );
  }
}

Future<Response> _onPost(RequestContext context) async {
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

  final payloadStoreId = body['storeId'];
  if (payloadStoreId != null && payloadStoreId is! String) {
    return _invalidInput('storeId', 'Must be a valid UUID string');
  }

  if (payloadStoreId != null &&
      payloadStoreId is String &&
      !Uuid.isValidUUID(fromString: payloadStoreId)) {
    return _invalidInput('storeId', 'Must be a valid UUID string');
  }

  if (payloadStoreId != null && payloadStoreId != storeId) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.forbidden,
      code: 'STORE_SCOPE_MISMATCH',
      message: 'Order store scope does not match authenticated cashier store.',
    );
  }

  final customerId = body['customerId'];
  if (customerId != null && customerId is! String) {
    return _invalidInput('customerId', 'Must be a valid UUID string');
  }

  if (customerId != null &&
      customerId is String &&
      !Uuid.isValidUUID(fromString: customerId)) {
    return _invalidInput('customerId', 'Must be a valid UUID string');
  }

  final notes = body['notes'];
  if (notes != null && notes is! String) {
    return _invalidInput('notes', 'Must be a string');
  }

  if (notes != null && notes is String && notes.length > 1000) {
    return _invalidInput('notes', 'Must not exceed 1000 characters');
  }

  final items = body['items'];
  if (items is! List || items.isEmpty) {
    return _invalidInput('items', 'Must be a non-empty array');
  }

  final computedItems = <Map<String, dynamic>>[];
  num subtotal = 0;
  num gstAmount = 0;

  for (var i = 0; i < items.length; i++) {
    final item = items[i];
    if (item is! Map<String, dynamic>) {
      return _invalidInput('items[$i]', 'Must be an object');
    }

    final menuItemId = item['menuItemId'];
    if (menuItemId is! String || !Uuid.isValidUUID(fromString: menuItemId)) {
      return _invalidInput('items[$i].menuItemId', 'Must be a valid UUID');
    }

    final itemName = item['itemName'];
    if (itemName is! String || itemName.trim().isEmpty) {
      return _invalidInput('items[$i].itemName', 'Must be a non-empty string');
    }

    final quantity = item['quantity'];
    if (quantity is! int || quantity <= 0) {
      return _invalidInput('items[$i].quantity', 'Must be an integer > 0');
    }

    final unitPrice = item['unitPrice'];
    if (unitPrice is! num || unitPrice < 0) {
      return _invalidInput('items[$i].unitPrice', 'Must be a number >= 0');
    }

    final gstPercentRaw = item['gstPercent'];
    final gstPercent = gstPercentRaw ?? 0;
    if (gstPercent is! num || gstPercent < 0) {
      return _invalidInput('items[$i].gstPercent', 'Must be a number >= 0');
    }

    final lineTotal = unitPrice * quantity;
    final itemGstAmount = (lineTotal * gstPercent) / 100;

    subtotal += lineTotal;
    gstAmount += itemGstAmount;

    computedItems.add({
      'menuItemId': menuItemId,
      'itemName': itemName.trim(),
      'quantity': quantity,
      'unitPrice': unitPrice,
      'gstPercent': gstPercent,
      'lineTotal': lineTotal,
      'gstAmount': itemGstAmount,
    });
  }

  final total = subtotal + gstAmount;

  final orderRepository = OrderRepository(
    pool: context.read<Pool<String>>(),
  );

  late final Map<String, dynamic>? createdOrder;
  try {
    createdOrder = await orderRepository.createForCashier(
      tenantId: tenantId,
      storeId: storeId,
      cashierId: tokenPayload.id,
      customerId: customerId as String?,
      notes: notes as String?,
      items: computedItems,
      subtotal: subtotal,
      gstAmount: gstAmount,
      total: total,
    );
  } catch (_) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.internalServerError,
      code: 'ORDER_CREATION_FAILED',
      message: 'Failed to create order.',
    );
  }

  if (createdOrder == null) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.notFound,
      code: 'STORE_NOT_FOUND',
      message: 'Store not found or not accessible.',
    );
  }

  return ResponseHelper.success(
    statusCode: HttpStatus.created,
    message: 'Order created successfully.',
    data: {
      'order': createdOrder,
    },
  );
}

Response _invalidInput(String field, String message) {
  return ResponseHelper.problem(
    statusCode: HttpStatus.badRequest,
    code: 'INVALID_INPUT',
    message: 'Invalid order payload.',
    details: {
      field: [message],
    },
  );
}
