import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:loxia/loxia.dart';
import 'package:pos_backend/models/merchant/merchant.dart';
import 'package:pos_backend/models/stock_movement/stock_movement.dart';
import 'package:uuid/uuid.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    .get => _getStockMovements(context),
    _ => Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {'status': 'error', 'message': 'Method not allowed.'},
    ),
  };
}

Future<Response> _getStockMovements(RequestContext context) async {
  final params = context.request.uri.queryParameters;
  final storeId = params['storeId'];
  final productId = params['productId'];
  final page = int.tryParse(params['page'] ?? '');
  final pageSize = int.tryParse(params['pageSize'] ?? '');

  if (storeId == null) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'status': 'error', 'message': 'Store ID is required.'},
    );
  }

  if (!Uuid.isValidUUID(fromString: storeId)) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'status': 'error', 'message': 'Store ID must be a valid UUID.'},
    );
  }

  if (productId != null && !Uuid.isValidUUID(fromString: productId)) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'status': 'error', 'message': 'Product ID must be a valid UUID.'},
    );
  }

  final merchant = context.read<Merchant>();
  final movements = context.read<DataSource>().getRepository<StockMovement>();

  try {
    final where = productId == null
        ? StockMovementQuery(
            (m) => m.storeId
                .equals(storeId)
                .and(m.store.merchantId.equals(merchant.id)),
          )
        : StockMovementQuery(
            (m) => m.storeId
                .equals(storeId)
                .and(m.productId.equals(productId))
                .and(m.store.merchantId.equals(merchant.id)),
          );

    final paginated = await movements.paginate(
      where: where,
      orderBy: [const OrderBy('created_at', ascending: false)],
      page: page ?? 1,
      pageSize: pageSize ?? 10,
      maxPageSize: 100,
    );

    return Response.json(
      body: {
        'status': 'success',
        'paginatedResult': paginated,
      },
    );
  } on Exception {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Unable to fetch stock movements at the moment.',
      },
    );
  }
}
