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
  final eventIdHeader = context.request.headers['x-phonepe-event-id']?.trim();
  final eventTimestampHeader = context
      .request
      .headers['x-phonepe-event-timestamp']
      ?.trim();

  final configuredSecret = Env.phonepeWebhookSecret;
  if (configuredSecret != null && configuredSecret.isNotEmpty) {
    final providedSignature = context.request.headers['x-phonepe-signature'];
    final expectedSignature = _hmacSha256Hex(rawBody, configuredSecret);
    final normalizedSignature = _normalizeSignature(providedSignature);

    if (normalizedSignature == null ||
        !_constantTimeEquals(
          normalizedSignature,
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

  final eventId = _extractEventId(body) ?? eventIdHeader;
  if (eventId == null || eventId.isEmpty) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_INPUT',
      message: 'Invalid webhook payload.',
      details: {
        'eventId': [
          'x-phonepe-event-id header or payload event id is required',
        ],
      },
    );
  }

  final eventTimestampRaw =
      _extractEventTimestamp(body) ?? eventTimestampHeader;
  final eventTimestamp = _parseWebhookEventTimestamp(eventTimestampRaw);
  if (eventTimestamp == null) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_INPUT',
      message: 'Invalid webhook payload.',
      details: {
        'eventTimestamp': [
          'x-phonepe-event-timestamp header or payload timestamp is invalid',
        ],
      },
    );
  }

  final now = DateTime.now().toUtc();
  final maxSkewSeconds = Env.phonepeWebhookMaxSkewSeconds;
  final skew = now.difference(eventTimestamp).inSeconds.abs();
  if (skew > maxSkewSeconds) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.unauthorized,
      code: 'WEBHOOK_EXPIRED',
      message: 'Webhook event timestamp is outside allowed window.',
    );
  }

  final merchantOrderId = _extractMerchantOrderId(body);
  if (merchantOrderId == null || merchantOrderId.isEmpty) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_INPUT',
      message: 'Invalid webhook payload.',
      details: {
        'merchantOrderId': ['Must be a non-empty string'],
      },
    );
  }

  final normalizedStatus = _normalizeWebhookStatus(_extractStatus(body));
  if (normalizedStatus == null) {
    return ResponseHelper.problem(
      statusCode: HttpStatus.badRequest,
      code: 'INVALID_INPUT',
      message: 'Invalid webhook payload.',
      details: {
        'status': ['Must be one of: pending, paid, failed, refunded'],
      },
    );
  }

  final phonepeOrderId = _extractStringValue(
    body,
    keys: const ['phonepeOrderId', 'phonepe_order_id', 'providerOrderId'],
  );
  final phonepeTransactionId = _extractStringValue(
    body,
    keys: const [
      'phonepeTransactionId',
      'phonepe_transaction_id',
      'providerTransactionId',
      'transactionId',
    ],
  );
  final phonepeState = _extractStringValue(
    body,
    keys: const ['phonepeState', 'phonepe_state', 'providerState', 'state'],
  );
  final phonepePaymentMode = _extractStringValue(
    body,
    keys: const [
      'phonepePaymentMode',
      'phonepe_payment_mode',
      'providerPaymentMode',
      'paymentMode',
    ],
  );
  final rawResponse = _extractRawResponse(body);
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
      status: normalizedStatus,
      webhookEventId: eventId,
      webhookEventTimestamp: eventTimestamp,
      payloadHash: sha256.convert(utf8.encode(rawBody)).toString(),
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
  final isReplayEvent = payment['isReplayEvent'] == true;

  return ResponseHelper.success(
    message: isReplayEvent
        ? 'Webhook event replay detected; request ignored.'
        : isDuplicateEvent
        ? 'Webhook event already processed.'
        : 'Webhook processed successfully.',
    data: {
      'payment': payment,
    },
  );
}

DateTime? _parseWebhookEventTimestamp(String? raw) {
  if (raw == null || raw.isEmpty) {
    return null;
  }

  final asInt = int.tryParse(raw);
  if (asInt != null) {
    // Accept epoch seconds and epoch milliseconds.
    if (raw.length >= 13) {
      return DateTime.fromMillisecondsSinceEpoch(asInt, isUtc: true);
    }
    return DateTime.fromMillisecondsSinceEpoch(asInt * 1000, isUtc: true);
  }

  final parsed = DateTime.tryParse(raw);
  return parsed?.toUtc();
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

String? _normalizeSignature(String? headerValue) {
  if (headerValue == null) {
    return null;
  }

  final trimmed = headerValue.trim();
  if (trimmed.isEmpty) {
    return null;
  }

  const sha256Prefix = 'sha256=';
  final lower = trimmed.toLowerCase();
  if (lower.startsWith(sha256Prefix)) {
    final stripped = trimmed.substring(sha256Prefix.length).trim();
    return stripped.isEmpty ? null : stripped.toLowerCase();
  }

  return lower;
}

String? _extractEventId(Map<String, dynamic> body) {
  return _extractStringValue(
    body,
    keys: const ['eventId', 'event_id', 'callbackId', 'callback_id'],
  );
}

String? _extractEventTimestamp(Map<String, dynamic> body) {
  const keys = [
    'eventTimestamp',
    'event_timestamp',
    'eventTime',
    'event_time',
    'timestamp',
  ];

  final direct = _findTimestamp(body, keys);
  if (direct != null) {
    return direct;
  }

  for (final nestedMap in _nestedMaps(body)) {
    final nested = _findTimestamp(nestedMap, keys);
    if (nested != null) {
      return nested;
    }
  }

  return null;
}

String? _extractMerchantOrderId(Map<String, dynamic> body) {
  return _extractStringValue(
    body,
    keys: const [
      'merchantOrderId',
      'merchant_order_id',
      'merchantTransactionId',
      'merchant_transaction_id',
    ],
  );
}

String? _extractStatus(Map<String, dynamic> body) {
  return _extractStringValue(
    body,
    keys: const ['status', 'paymentStatus', 'payment_status', 'state'],
  );
}

String? _normalizeWebhookStatus(String? rawStatus) {
  if (rawStatus == null || rawStatus.trim().isEmpty) {
    return null;
  }

  final normalized = rawStatus.trim().toLowerCase();
  return switch (normalized) {
    'pending' || 'created' || 'initiated' => 'pending',
    'paid' || 'success' || 'succeeded' || 'completed' => 'paid',
    'failed' || 'failure' || 'declined' => 'failed',
    'refunded' || 'refund' => 'refunded',
    _ => null,
  };
}

String? _extractStringValue(
  Map<String, dynamic> body, {
  required List<String> keys,
}) {
  final direct = _findString(body, keys);
  if (direct != null) {
    return direct;
  }

  for (final nestedMap in _nestedMaps(body)) {
    final nested = _findString(nestedMap, keys);
    if (nested != null) {
      return nested;
    }
  }

  return null;
}

String? _findString(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = source[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return null;
}

String? _findTimestamp(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = source[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    if (value is int || value is double) {
      return value.toString();
    }
  }
  return null;
}

Object? _extractRawResponse(Map<String, dynamic> body) {
  final direct = body['phonepeRawResponse'];
  if (direct != null) {
    return direct;
  }

  for (final nestedMap in _nestedMaps(body)) {
    if (nestedMap['phonepeRawResponse'] != null) {
      return nestedMap['phonepeRawResponse'];
    }
  }

  return null;
}

Iterable<Map<String, dynamic>> _nestedMaps(Map<String, dynamic> body) sync* {
  final data = body['data'];
  if (data is Map<String, dynamic>) {
    yield data;
  }

  final payment = body['payment'];
  if (payment is Map<String, dynamic>) {
    yield payment;
  }

  final payload = body['payload'];
  if (payload is Map<String, dynamic>) {
    yield payload;
  }
}
