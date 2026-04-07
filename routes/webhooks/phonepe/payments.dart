import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
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
  final rawBody = await context.request.body();

  final configuredSecret = Env.phonepeWebhookSecret;
  if (configuredSecret != null && configuredSecret.isNotEmpty) {
    final providedSignature = context.request.headers['x-phonepe-signature'];
    final expectedSignature = _hmacSha256Hex(rawBody, configuredSecret);

    if (providedSignature == null ||
        !_constantTimeEquals(
          providedSignature.trim().toLowerCase(),
          expectedSignature,
        )) {
      return ResponseHelper.problem(
        statusCode: HttpStatus.unauthorized,
        code: 'WEBHOOK_UNAUTHORIZED',
        message: 'Invalid webhook signature.',
      );
    }
  }

  late final Map<String, dynamic> body;
  try {
    body = jsonDecode(rawBody) as Map<String, dynamic>;
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

  final isDuplicateEvent = payment['isDuplicateEvent'] == true;

  return ResponseHelper.success(
    message: isDuplicateEvent
        ? 'Webhook event already processed.'
        : 'Webhook processed successfully.',
    data: {
      'payment': payment,
    },
  );
}

String _hmacSha256Hex(String payload, String secret) {
  final hmac = Hmac(sha256, utf8.encode(secret));
  final digest = hmac.convert(utf8.encode(payload));
  return digest.toString();
}

bool _constantTimeEquals(String a, String b) {
  if (a.length != b.length) {
    return false;
  }

  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return diff == 0;
}
