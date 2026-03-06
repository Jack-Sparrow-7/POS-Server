import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:loxia/loxia.dart';
import 'package:pos_backend/enums/stock_change_reason.dart';
import 'package:pos_backend/models/merchant/merchant.dart';
import 'package:pos_backend/services/stock_movement_service.dart';
import 'package:pos_backend/utils/json_body_parser.dart';
import 'package:pos_backend/validators/stock_validators.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {'status': 'error', 'message': 'Method not allowed.'},
    );
  }

  final parsedBody = await parseJsonObjectBody(context.request);
  if (parsedBody.errorResponse != null) return parsedBody.errorResponse!;

  final result = StockValidators.reduceSchema.tryParse(parsedBody.body!);
  if (!result.success) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {
        'status': 'error',
        'message': 'Request validation failed.',
        'errors': result.errors,
      },
    );
  }

  final body = result.value;
  final merchant = context.read<Merchant>();

  try {
    final reason = StockChangeReason.values.byName(body['reason'] as String);
    final movementResult = await StockMovementService.apply(
      dataSource: context.read<DataSource>(),
      merchantId: merchant.id,
      storeId: body['storeId'] as String,
      productId: body['productId'] as String,
      reason: reason,
      quantity: (body['quantity'] as num).toInt(),
      note: body['note'] as String?,
    );

    return Response.json(
      body: {
        'status': 'success',
        'stock': movementResult.stock,
        'movement': movementResult.movement,
        'message': 'Stock reduced successfully.',
      },
    );
  } on StockMovementException catch (e) {
    if (e.code == StockMovementErrorCode.notFound) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {
          'status': 'error',
          'message': 'Stock record not found for this product in this store.',
        },
      );
    }
    if (e.code == StockMovementErrorCode.insufficientStock) {
      return Response.json(
        statusCode: HttpStatus.conflict,
        body: {
          'status': 'error',
          'message': 'Insufficient stock. Operation blocked.',
        },
      );
    }
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Unable to reduce stock at the moment.',
      },
    );
  } on Exception {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Unable to reduce stock at the moment.',
      },
    );
  }
}
