import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:pos_server/models/token_payload.dart';
import 'package:pos_server/repositories/payment_repository.dart';
import 'package:pos_server/utils/response_helper.dart';
import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';

Future<Response> onRequest(
  RequestContext context,
  String id,
) async {
  return switch (context.request.method) {
    .get => _onGet(context, id),
    .post => _onPost(context, id),
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

  final merchantOrderId =
      context.request.uri.queryParameters['merchantOrderId'];
  if (merchantOrderId != null && merchantOrderId.trim().isEmpty) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_INPUT',
      message: 'Invalid payment query payload.',
      details: {
        'merchantOrderId': ['Must be a non-empty string when provided'],
      },
    );
  }

  final paymentRepository = PaymentRepository(
    pool: context.read<Pool<String>>(),
  );

  late final Map<String, dynamic> result;
  try {
    result = await paymentRepository.fetchStatusForCashierOrder(
      tenantId: tenantId,
      storeId: storeId,
      orderId: id,
      merchantOrderId: merchantOrderId?.trim(),
    );
  } catch (_) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.internalServerError,
      code: 'PAYMENT_FETCH_FAILED',
      message: 'Failed to fetch payment status.',
    );
  }

  final orderExists = result['orderExists'] as bool;
  final payment = result['payment'] as Map<String, dynamic>?;

  if (!orderExists) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.notFound,
      code: 'ORDER_NOT_FOUND',
      message: 'Order not found.',
    );
  }

  if (payment == null) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.notFound,
      code: 'PAYMENT_NOT_FOUND',
      message: 'Payment not found for this order.',
    );
  }

  return ResponseHelper.success(
    message: 'Payment status fetched successfully.',
    data: {
      'payment': payment,
    },
  );
}

Future<Response> _onPost(RequestContext context, String id) async {
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

  final paymentMethod = body['paymentMethod'];
  const allowedMethods = {'cash', 'upi_walk_in', 'card'};

  if (paymentMethod is! String || !allowedMethods.contains(paymentMethod)) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_INPUT',
      message: 'Invalid payment initiation payload.',
      details: {
        'paymentMethod': [
          'Must be one of: cash, upi_walk_in, card',
        ],
      },
    );
  }

  final paymentRepository = PaymentRepository(
    pool: context.read<Pool<String>>(),
  );

  late final Map<String, dynamic>? payment;
  try {
    payment = await paymentRepository.initiateForCashierOrder(
      tenantId: tenantId,
      storeId: storeId,
      orderId: id,
      paymentMethod: paymentMethod,
    );
  } on OrderPaymentNotPendingException {
    return ResponseHelper.problem(
      statusCode: HttpStatus.conflict,
      code: 'ORDER_PAYMENT_NOT_PENDING',
      message: 'Order payment is not pending.',
    );
  } on PaymentAlreadyInitiatedException {
    return ResponseHelper.problem(
      statusCode: HttpStatus.conflict,
      code: 'PAYMENT_ALREADY_INITIATED',
      message: 'Pending payment already exists for this order.',
    );
  } catch (_) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.internalServerError,
      code: 'PAYMENT_INITIATION_FAILED',
      message: 'Failed to initiate payment.',
    );
  }

  if (payment == null) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.notFound,
      code: 'ORDER_NOT_FOUND',
      message: 'Order not found.',
    );
  }

  return ResponseHelper.success(
    statusCode: HttpStatus.created,
    message: 'Payment initiated successfully.',
    data: {
      'payment': payment,
    },
  );
}
