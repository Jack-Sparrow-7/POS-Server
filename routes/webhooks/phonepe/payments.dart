import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:pos_server/config/env.dart';
import 'package:pos_server/repositories/payment_repository.dart';
import 'package:pos_server/utils/response_helper.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.methodNotAllowed,
      code: 'METHOD_NOT_ALLOWED',
      message: 'Method not allowed',
    );
  }

  return _onPost(context);
}

Future<Response> _onPost(RequestContext context) async {
  final configuredSecret = Env.phonepeWebhookSecret;
  if (configuredSecret != null && configuredSecret.isNotEmpty) {
    final providedSecret = context.request.headers['x-webhook-secret'];
    if (providedSecret == null || providedSecret != configuredSecret) {
      return ResponseHelper.problem(
        statusCode: HttpStatus.unauthorized,
        code: 'WEBHOOK_UNAUTHORIZED',
        message: 'Invalid webhook credentials.',
      );
    }
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

  final merchantOrderIdRaw = body['merchantOrderId'];
  if (merchantOrderIdRaw is! String || merchantOrderIdRaw.trim().isEmpty) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_INPUT',
      message: 'Invalid webhook payload.',
      details: {
        'merchantOrderId': ['Must be a non-empty string'],
      },
    );
  }
  final merchantOrderId = merchantOrderIdRaw.trim();

  final status = body['status'];
  const allowedStatuses = {'pending', 'paid', 'failed', 'refunded'};
  if (status is! String || !allowedStatuses.contains(status)) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_INPUT',
      message: 'Invalid webhook payload.',
      details: {
        'status': ['Must be one of: pending, paid, failed, refunded'],
      },
    );
  }

  final phonepeOrderId = (body['phonepeOrderId'] as String?)?.trim();
  final phonepeTransactionId = (body['phonepeTransactionId'] as String?)
      ?.trim();
  final phonepeState = (body['phonepeState'] as String?)?.trim();
  final phonepePaymentMode = (body['phonepePaymentMode'] as String?)?.trim();
  final rawResponse = body['phonepeRawResponse'];
  if (rawResponse != null && rawResponse is! Map<String, dynamic>) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_INPUT',
      message: 'Invalid webhook payload.',
      details: {
        'phonepeRawResponse': ['Must be an object when provided'],
      },
    );
  }

  final paymentRepository = PaymentRepository(
    pool: context.read<Pool<String>>(),
  );

  late final Map<String, dynamic>? payment;
  try {
    payment = await paymentRepository.syncStatusByMerchantOrderId(
      merchantOrderId: merchantOrderId,
      status: status,
      phonepeOrderId: phonepeOrderId,
      phonepeTransactionId: phonepeTransactionId,
      phonepeState: phonepeState,
      phonepePaymentMode: phonepePaymentMode,
      phonepeRawResponse: rawResponse as Map<String, dynamic>?,
    );
  } catch (_) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.internalServerError,
      code: 'WEBHOOK_PROCESSING_FAILED',
      message: 'Failed to process webhook.',
    );
  }

  if (payment == null) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.notFound,
      code: 'PAYMENT_NOT_FOUND',
      message: 'Payment not found.',
    );
  }

  return ResponseHelper.success(
    message: 'Webhook processed successfully.',
    data: {
      'payment': payment,
    },
  );
}
