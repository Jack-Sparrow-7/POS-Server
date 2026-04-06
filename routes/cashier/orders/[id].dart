import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:pos_server/models/token_payload.dart';
import 'package:pos_server/repositories/order_repository.dart';
import 'package:pos_server/utils/response_helper.dart';
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
  final storeId = tokenPayload.storeId;

  if (tenantId == null || storeId == null) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.unauthorized,
      code: 'UNAUTHORIZED',
      message: 'Tenant or store ID is missing in token payload.',
    );
  }

  final repository = OrderRepository(
    pool: context.read<Pool<String>>(),
  );

  late final Map<String, dynamic>? order;
  try {
    order = await repository.findByIdForCashierStore(
      id: id,
      tenantId: tenantId,
      storeId: storeId,
    );
  } catch (_) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.internalServerError,
      code: 'ORDER_FETCH_FAILED',
      message: 'Failed to fetch order.',
    );
  }

  if (order == null) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.notFound,
      code: 'ORDER_NOT_FOUND',
      message: 'Order not found.',
    );
  }

  return ResponseHelper.success(
    message: 'Order fetched successfully.',
    data: {
      'order': order,
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

  final status = body['status'];
  const allowedStatuses = {
    'confirmed',
    'ready',
    'completed',
    'cancelled',
  };

  if (status is! String || !allowedStatuses.contains(status)) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_INPUT',
      message: 'Invalid order status payload.',
      details: {
        'status': [
          'Must be one of: confirmed, ready, completed, cancelled',
        ],
      },
    );
  }

  final repository = OrderRepository(
    pool: context.read<Pool<String>>(),
  );

  late final Map<String, dynamic>? order;
  try {
    order = await repository.updateStatusForCashierStore(
      id: id,
      tenantId: tenantId,
      storeId: storeId,
      nextStatus: status,
    );
  } on InvalidOrderStatusTransitionException {
    return ResponseHelper.problem(
      statusCode: HttpStatus.conflict,
      code: 'INVALID_STATUS_TRANSITION',
      message: 'Order status transition is not allowed.',
    );
  } catch (_) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.internalServerError,
      code: 'ORDER_STATUS_UPDATE_FAILED',
      message: 'Failed to update order status.',
    );
  }

  if (order == null) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.notFound,
      code: 'ORDER_NOT_FOUND',
      message: 'Order not found.',
    );
  }

  return ResponseHelper.success(
    message: 'Order status updated successfully.',
    data: {
      'order': order,
    },
  );
}
