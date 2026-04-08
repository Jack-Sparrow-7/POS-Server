import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pos_server/config/env.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

import '../../../../routes/webhooks/phonepe/payments.dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

class _MockPool extends Mock implements Pool<String> {}

void main() {
  group('GET /webhooks/phonepe/payments', () {
    test('responds with a 405 when method is not allowed', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.get(Uri.parse('http://127.0.0.1/webhooks/phonepe/payments')),
      );

      final response = await route.onRequest(context);

      expect(response.statusCode, HttpStatus.methodNotAllowed);
      final body = await response.json() as Map<String, dynamic>;
      final code = (body['error'] as Map<String, dynamic>)['code'] as String;
      expect(code, 'METHOD_NOT_ALLOWED');
    });
  });

  group('POST /webhooks/phonepe/payments', () {
    setUp(Env.clearTestOverrides);

    tearDown(Env.clearTestOverrides);

    test('returns 400 INVALID_JSON for malformed request body', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.post(
          Uri.parse('http://127.0.0.1/webhooks/phonepe/payments'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            'x-phonepe-event-id': 'evt-1',
            'x-phonepe-event-timestamp': DateTime.now()
                .toUtc()
                .millisecondsSinceEpoch
                .toString(),
          },
          body: '{invalid',
        ),
      );

      final response = await route.onRequest(context);

      expect(response.statusCode, HttpStatus.badRequest);
      final body = await response.json() as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'INVALID_JSON');
    });

    test('returns 400 INVALID_INPUT when event id header is missing', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.post(
          Uri.parse('http://127.0.0.1/webhooks/phonepe/payments'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            'x-phonepe-event-timestamp': DateTime.now()
                .toUtc()
                .millisecondsSinceEpoch
                .toString(),
          },
          body: '{"merchantOrderId":"MORD-1","status":"paid"}',
        ),
      );

      final response = await route.onRequest(context);

      expect(response.statusCode, HttpStatus.badRequest);
      final body = await response.json() as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'INVALID_INPUT');
    });

    test(
      'accepts event metadata and payment fields from body without headers',
      () async {
        final context = _MockRequestContext();
        final pool = _MockPool();
        final nowMillis = DateTime.now().toUtc().millisecondsSinceEpoch;
        when(() => context.request).thenReturn(
          Request.post(
            Uri.parse('http://127.0.0.1/webhooks/phonepe/payments'),
            headers: {
              HttpHeaders.contentTypeHeader: 'application/json',
            },
            body: [
              '{"event_id":"evt-body-1",',
              '"event_timestamp":$nowMillis,',
              '"data":{"merchant_order_id":"MORD-BODY-1",',
              '"status":"SUCCESS"}}',
            ].join(),
          ),
        );
        when(() => context.read<Pool<String>>()).thenReturn(pool);
        when(
          () => pool.runTx<Map<String, dynamic>?>(any()),
        ).thenAnswer(
          (_) async => {
            'id': '770e8400-e29b-41d4-a716-446655440001',
            'orderId': '550e8400-e29b-41d4-a716-446655440000',
            'storeId': '550e8400-e29b-41d4-a716-446655440222',
            'amount': 165.9,
            'status': 'paid',
            'merchantOrderId': 'MORD-BODY-1',
            'phonepeOrderId': null,
            'phonepeTransactionId': null,
            'phonepeState': null,
            'phonepePaymentMode': null,
            'initiatedAt': '2026-04-06T12:00:00.000Z',
            'paidAt': '2026-04-06T12:01:00.000Z',
            'failedAt': null,
            'refundedAt': null,
          },
        );

        final response = await route.onRequest(context);

        expect(response.statusCode, HttpStatus.ok);
        final body = await response.json() as Map<String, dynamic>;
        expect(body['success'], isTrue);
      },
    );

    test('returns 400 INVALID_INPUT when event timestamp is invalid', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.post(
          Uri.parse('http://127.0.0.1/webhooks/phonepe/payments'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            'x-phonepe-event-id': 'evt-1',
            'x-phonepe-event-timestamp': 'not-a-time',
          },
          body: '{"merchantOrderId":"MORD-1","status":"paid"}',
        ),
      );

      final response = await route.onRequest(context);

      expect(response.statusCode, HttpStatus.badRequest);
      final body = await response.json() as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'INVALID_INPUT');
    });

    test('returns 401 WEBHOOK_EXPIRED when event timestamp is stale', () async {
      final context = _MockRequestContext();
      final staleTimestamp = DateTime.now()
          .toUtc()
          .subtract(const Duration(hours: 2))
          .millisecondsSinceEpoch
          .toString();

      when(() => context.request).thenReturn(
        Request.post(
          Uri.parse('http://127.0.0.1/webhooks/phonepe/payments'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            'x-phonepe-event-id': 'evt-1',
            'x-phonepe-event-timestamp': staleTimestamp,
          },
          body: '{"merchantOrderId":"MORD-1","status":"paid"}',
        ),
      );

      final response = await route.onRequest(context);

      expect(response.statusCode, HttpStatus.unauthorized);
      final body = await response.json() as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'WEBHOOK_EXPIRED');
    });

    test('returns 400 INVALID_INPUT for missing merchantOrderId', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.post(
          Uri.parse('http://127.0.0.1/webhooks/phonepe/payments'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            'x-phonepe-event-id': 'evt-1',
            'x-phonepe-event-timestamp': DateTime.now()
                .toUtc()
                .millisecondsSinceEpoch
                .toString(),
          },
          body: '{"status":"paid"}',
        ),
      );

      final response = await route.onRequest(context);

      expect(response.statusCode, HttpStatus.badRequest);
      final body = await response.json() as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'INVALID_INPUT');
    });

    test('returns 400 INVALID_INPUT for invalid status', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.post(
          Uri.parse('http://127.0.0.1/webhooks/phonepe/payments'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            'x-phonepe-event-id': 'evt-1',
            'x-phonepe-event-timestamp': DateTime.now()
                .toUtc()
                .millisecondsSinceEpoch
                .toString(),
          },
          body: '{"merchantOrderId":"MORD-1","status":"processing"}',
        ),
      );

      final response = await route.onRequest(context);

      expect(response.statusCode, HttpStatus.badRequest);
      final body = await response.json() as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'INVALID_INPUT');
    });

    test('accepts provider status alias SUCCESS as paid', () async {
      final context = _MockRequestContext();
      final pool = _MockPool();
      when(() => context.request).thenReturn(
        Request.post(
          Uri.parse('http://127.0.0.1/webhooks/phonepe/payments'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            'x-phonepe-event-id': 'evt-1',
            'x-phonepe-event-timestamp': DateTime.now()
                .toUtc()
                .millisecondsSinceEpoch
                .toString(),
          },
          body: '{"merchantOrderId":"MORD-1","status":"SUCCESS"}',
        ),
      );
      when(() => context.read<Pool<String>>()).thenReturn(pool);
      when(
        () => pool.runTx<Map<String, dynamic>?>(any()),
      ).thenAnswer(
        (_) async => {
          'id': '770e8400-e29b-41d4-a716-446655440001',
          'orderId': '550e8400-e29b-41d4-a716-446655440000',
          'storeId': '550e8400-e29b-41d4-a716-446655440222',
          'amount': 165.9,
          'status': 'paid',
          'merchantOrderId': 'MORD-1',
          'phonepeOrderId': null,
          'phonepeTransactionId': null,
          'phonepeState': null,
          'phonepePaymentMode': null,
          'initiatedAt': '2026-04-06T12:00:00.000Z',
          'paidAt': '2026-04-06T12:01:00.000Z',
          'failedAt': null,
          'refundedAt': null,
        },
      );

      final response = await route.onRequest(context);

      expect(response.statusCode, HttpStatus.ok);
      final body = await response.json() as Map<String, dynamic>;
      expect(body['success'], isTrue);
      final payment =
          (body['data'] as Map<String, dynamic>)['payment']
              as Map<String, dynamic>;
      expect(payment['status'], 'paid');
    });

    test(
      'returns 401 WEBHOOK_UNAUTHORIZED when signature is missing',
      () async {
        Env.overrideForTesting('PHONEPE_WEBHOOK_SECRET', 'test-secret');

        final context = _MockRequestContext();
        when(() => context.request).thenReturn(
          Request.post(
            Uri.parse('http://127.0.0.1/webhooks/phonepe/payments'),
            headers: {
              HttpHeaders.contentTypeHeader: 'application/json',
              'x-phonepe-event-id': 'evt-1',
              'x-phonepe-event-timestamp': DateTime.now()
                  .toUtc()
                  .millisecondsSinceEpoch
                  .toString(),
            },
            body: '{"merchantOrderId":"MORD-1","status":"paid"}',
          ),
        );

        final response = await route.onRequest(context);

        expect(response.statusCode, HttpStatus.unauthorized);
        final body = await response.json() as Map<String, dynamic>;
        final error = body['error'] as Map<String, dynamic>;
        expect(error['code'], 'WEBHOOK_UNAUTHORIZED');
      },
    );

    test(
      'returns 401 WEBHOOK_UNAUTHORIZED for invalid signature',
      () async {
        Env.overrideForTesting('PHONEPE_WEBHOOK_SECRET', 'test-secret');

        final context = _MockRequestContext();
        when(() => context.request).thenReturn(
          Request.post(
            Uri.parse('http://127.0.0.1/webhooks/phonepe/payments'),
            headers: {
              HttpHeaders.contentTypeHeader: 'application/json',
              'x-phonepe-event-id': 'evt-1',
              'x-phonepe-event-timestamp': DateTime.now()
                  .toUtc()
                  .millisecondsSinceEpoch
                  .toString(),
              'x-phonepe-signature': 'invalid',
            },
            body: '{"merchantOrderId":"MORD-1","status":"paid"}',
          ),
        );

        final response = await route.onRequest(context);

        expect(response.statusCode, HttpStatus.unauthorized);
        final body = await response.json() as Map<String, dynamic>;
        final error = body['error'] as Map<String, dynamic>;
        expect(error['code'], 'WEBHOOK_UNAUTHORIZED');
      },
    );

    test('accepts webhook when signature is valid', () async {
      Env.overrideForTesting('PHONEPE_WEBHOOK_SECRET', 'test-secret');

      final context = _MockRequestContext();
      final pool = _MockPool();
      const payload = '{"merchantOrderId":"MORD-1","status":"paid"}';
      const signature =
          '9c3409df989cc27a7574b5af5872d69799457c696bd49d3f293ef84b3f761121';

      when(() => context.request).thenReturn(
        Request.post(
          Uri.parse('http://127.0.0.1/webhooks/phonepe/payments'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            'x-phonepe-event-id': 'evt-1',
            'x-phonepe-event-timestamp': DateTime.now()
                .toUtc()
                .millisecondsSinceEpoch
                .toString(),
            'x-phonepe-signature': signature,
          },
          body: payload,
        ),
      );
      when(() => context.read<Pool<String>>()).thenReturn(pool);
      when(
        () => pool.runTx<Map<String, dynamic>?>(any()),
      ).thenAnswer(
        (_) async => {
          'id': '770e8400-e29b-41d4-a716-446655440001',
          'orderId': '550e8400-e29b-41d4-a716-446655440000',
          'storeId': '550e8400-e29b-41d4-a716-446655440222',
          'amount': 165.9,
          'status': 'paid',
          'merchantOrderId': 'MORD-1',
          'phonepeOrderId': null,
          'phonepeTransactionId': null,
          'phonepeState': null,
          'phonepePaymentMode': null,
          'initiatedAt': '2026-04-06T12:00:00.000Z',
          'paidAt': '2026-04-06T12:01:00.000Z',
          'failedAt': null,
          'refundedAt': null,
        },
      );

      final response = await route.onRequest(context);

      expect(response.statusCode, HttpStatus.ok);
      final body = await response.json() as Map<String, dynamic>;
      expect(body['success'], isTrue);
    });

    test(
      'returns 404 PAYMENT_NOT_FOUND when merchant order is unknown',
      () async {
        final context = _MockRequestContext();
        final pool = _MockPool();
        when(() => context.request).thenReturn(
          Request.post(
            Uri.parse('http://127.0.0.1/webhooks/phonepe/payments'),
            headers: {
              HttpHeaders.contentTypeHeader: 'application/json',
              'x-phonepe-event-id': 'evt-1',
              'x-phonepe-event-timestamp': DateTime.now()
                  .toUtc()
                  .millisecondsSinceEpoch
                  .toString(),
            },
            body: '{"merchantOrderId":"MORD-1","status":"paid"}',
          ),
        );
        when(() => context.read<Pool<String>>()).thenReturn(pool);
        when(
          () => pool.runTx<Map<String, dynamic>?>(any()),
        ).thenAnswer((_) async => null);

        final response = await route.onRequest(context);

        expect(response.statusCode, HttpStatus.notFound);
        final body = await response.json() as Map<String, dynamic>;
        final error = body['error'] as Map<String, dynamic>;
        expect(error['code'], 'PAYMENT_NOT_FOUND');
      },
    );

    test('returns 500 WEBHOOK_PROCESSING_FAILED on repository error', () async {
      final context = _MockRequestContext();
      final pool = _MockPool();
      when(() => context.request).thenReturn(
        Request.post(
          Uri.parse('http://127.0.0.1/webhooks/phonepe/payments'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            'x-phonepe-event-id': 'evt-1',
            'x-phonepe-event-timestamp': DateTime.now()
                .toUtc()
                .millisecondsSinceEpoch
                .toString(),
          },
          body: '{"merchantOrderId":"MORD-1","status":"paid"}',
        ),
      );
      when(() => context.read<Pool<String>>()).thenReturn(pool);
      when(
        () => pool.runTx<Map<String, dynamic>?>(any()),
      ).thenThrow(Exception('temporary db failure'));

      final response = await route.onRequest(context);

      expect(response.statusCode, HttpStatus.internalServerError);
      final body = await response.json() as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'WEBHOOK_PROCESSING_FAILED');
    });

    test(
      'returns 200 with payment payload on successful webhook sync',
      () async {
        final context = _MockRequestContext();
        final pool = _MockPool();
        when(() => context.request).thenReturn(
          Request.post(
            Uri.parse('http://127.0.0.1/webhooks/phonepe/payments'),
            headers: {
              HttpHeaders.contentTypeHeader: 'application/json',
              'x-phonepe-event-id': 'evt-1',
              'x-phonepe-event-timestamp': DateTime.now()
                  .toUtc()
                  .millisecondsSinceEpoch
                  .toString(),
            },
            body: [
              '{"merchantOrderId":"MORD-1712400000000-550e8400",',
              '"status":"paid","phonepeOrderId":"PPE-123"}',
            ].join(),
          ),
        );
        when(() => context.read<Pool<String>>()).thenReturn(pool);
        when(
          () => pool.runTx<Map<String, dynamic>?>(any()),
        ).thenAnswer(
          (_) async => {
            'id': '770e8400-e29b-41d4-a716-446655440001',
            'orderId': '550e8400-e29b-41d4-a716-446655440000',
            'storeId': '550e8400-e29b-41d4-a716-446655440222',
            'amount': 165.9,
            'status': 'paid',
            'merchantOrderId': 'MORD-1712400000000-550e8400',
            'phonepeOrderId': 'PPE-123',
            'phonepeTransactionId': null,
            'phonepeState': null,
            'phonepePaymentMode': null,
            'initiatedAt': '2026-04-06T12:00:00.000Z',
            'paidAt': '2026-04-06T12:01:00.000Z',
            'failedAt': null,
            'refundedAt': null,
          },
        );

        final response = await route.onRequest(context);

        expect(response.statusCode, HttpStatus.ok);
        final body = await response.json() as Map<String, dynamic>;
        expect(body['success'], isTrue);
        expect(body['message'], 'Webhook processed successfully.');
        final payment =
            (body['data'] as Map<String, dynamic>)['payment']
                as Map<String, dynamic>;
        expect(payment['status'], 'paid');
        expect(payment['merchantOrderId'], 'MORD-1712400000000-550e8400');
      },
    );

    test(
      'returns 200 with duplicate-event message when already applied',
      () async {
        final context = _MockRequestContext();
        final pool = _MockPool();
        when(() => context.request).thenReturn(
          Request.post(
            Uri.parse('http://127.0.0.1/webhooks/phonepe/payments'),
            headers: {
              HttpHeaders.contentTypeHeader: 'application/json',
              'x-phonepe-event-id': 'evt-1',
              'x-phonepe-event-timestamp': DateTime.now()
                  .toUtc()
                  .millisecondsSinceEpoch
                  .toString(),
            },
            body: '{"merchantOrderId":"MORD-1","status":"paid"}',
          ),
        );
        when(() => context.read<Pool<String>>()).thenReturn(pool);
        when(
          () => pool.runTx<Map<String, dynamic>?>(any()),
        ).thenAnswer(
          (_) async => {
            'id': '770e8400-e29b-41d4-a716-446655440001',
            'orderId': '550e8400-e29b-41d4-a716-446655440000',
            'storeId': '550e8400-e29b-41d4-a716-446655440222',
            'amount': 165.9,
            'status': 'paid',
            'merchantOrderId': 'MORD-1',
            'phonepeOrderId': null,
            'phonepeTransactionId': null,
            'phonepeState': null,
            'phonepePaymentMode': null,
            'initiatedAt': '2026-04-06T12:00:00.000Z',
            'paidAt': '2026-04-06T12:01:00.000Z',
            'failedAt': null,
            'refundedAt': null,
            'isDuplicateEvent': true,
          },
        );

        final response = await route.onRequest(context);

        expect(response.statusCode, HttpStatus.ok);
        final body = await response.json() as Map<String, dynamic>;
        expect(body['success'], isTrue);
        expect(body['message'], 'Webhook event already processed.');
      },
    );

    test(
      'returns 200 with replay-detected message for repeated event id',
      () async {
        final context = _MockRequestContext();
        final pool = _MockPool();
        when(() => context.request).thenReturn(
          Request.post(
            Uri.parse('http://127.0.0.1/webhooks/phonepe/payments'),
            headers: {
              HttpHeaders.contentTypeHeader: 'application/json',
              'x-phonepe-event-id': 'evt-replay-1',
              'x-phonepe-event-timestamp': DateTime.now()
                  .toUtc()
                  .millisecondsSinceEpoch
                  .toString(),
            },
            body: '{"merchantOrderId":"MORD-1","status":"paid"}',
          ),
        );
        when(() => context.read<Pool<String>>()).thenReturn(pool);
        when(
          () => pool.runTx<Map<String, dynamic>?>(any()),
        ).thenAnswer(
          (_) async => {
            'id': '770e8400-e29b-41d4-a716-446655440001',
            'orderId': '550e8400-e29b-41d4-a716-446655440000',
            'storeId': '550e8400-e29b-41d4-a716-446655440222',
            'amount': 165.9,
            'status': 'paid',
            'merchantOrderId': 'MORD-1',
            'phonepeOrderId': null,
            'phonepeTransactionId': null,
            'phonepeState': null,
            'phonepePaymentMode': null,
            'initiatedAt': '2026-04-06T12:00:00.000Z',
            'paidAt': '2026-04-06T12:01:00.000Z',
            'failedAt': null,
            'refundedAt': null,
            'isDuplicateEvent': true,
            'isReplayEvent': true,
          },
        );

        final response = await route.onRequest(context);

        expect(response.statusCode, HttpStatus.ok);
        final body = await response.json() as Map<String, dynamic>;
        expect(body['success'], isTrue);
        expect(
          body['message'],
          'Webhook event replay detected; request ignored.',
        );
      },
    );
  });
}
