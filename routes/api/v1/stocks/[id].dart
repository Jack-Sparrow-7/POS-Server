import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:loxia/loxia.dart';
import 'package:pos_backend/models/merchant/merchant.dart';
import 'package:pos_backend/models/stock/stock.dart';
import 'package:pos_backend/utils/json_body_parser.dart';
import 'package:pos_backend/validators/stock_validators.dart';
import 'package:uuid/uuid.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return switch (context.request.method) {
    .get => _getStock(context, id),
    .patch => _updateStock(context, id),
    _ => Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {'status': 'error', 'message': 'Method not allowed.'},
    ),
  };
}

Future<Response> _getStock(RequestContext context, String id) async {
  if (!Uuid.isValidUUID(fromString: id)) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'status': 'error', 'message': 'Id must be a uuid value.'},
    );
  }

  final stockRepo = context.read<DataSource>().getRepository<Stock>();
  final merchant = context.read<Merchant>();

  try {
    final stock = await stockRepo.findOneBy(
      where: StockQuery(
        (s) => s.id.equals(id).and(s.store.merchantId.equals(merchant.id)),
      ),
    );
    if (stock == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'status': 'error', 'message': 'Stock entry not found.'},
      );
    }

    return Response.json(
      body: {'status': 'success', 'stock': stock},
    );
  } on Exception {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Unable to fetch stock at the moment.',
      },
    );
  }
}

Future<Response> _updateStock(RequestContext context, String id) async {
  if (!Uuid.isValidUUID(fromString: id)) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'status': 'error', 'message': 'Id must be a uuid value.'},
    );
  }

  final parsedBody = await parseJsonObjectBody(context.request);

  if (parsedBody.errorResponse != null) {
    return parsedBody.errorResponse!;
  }

  final result = StockValidators.updateSchema.tryParse(parsedBody.body!);

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

  final quantity = (body['quantity'] as num?)?.toInt();
  final lowStockThreshold = (body['lowStockThreshold'] as num?)?.toInt();

  if (quantity == null && lowStockThreshold == null) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {
        'status': 'error',
        'message': 'Request body must include at least one updatable field.',
      },
    );
  }

  final stockRepo = context.read<DataSource>().getRepository<Stock>();
  final merchant = context.read<Merchant>();

  try {
    final stock = await stockRepo.findOneBy(
      where: StockQuery(
        (s) => s.id.equals(id).and(s.store.merchantId.equals(merchant.id)),
      ),
    );
    if (stock == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'status': 'error', 'message': 'Stock entry not found.'},
      );
    }
  } on Exception {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Unable to verify stock at the moment.',
      },
    );
  }

  try {
    final updatedStock = await stockRepo.save(
      StockPartial(
        id: id,
        quantity: quantity,
        lowStockThreshold: lowStockThreshold,
      ),
    );
    return Response.json(
      body: {
        'status': 'success',
        'stock': updatedStock,
        'message': 'Stock updated successfully.',
      },
    );
  } on Exception {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Unable to update stock at the moment.',
      },
    );
  }
}
