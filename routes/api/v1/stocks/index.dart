import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:loxia/loxia.dart';
import 'package:pos_backend/models/merchant/merchant.dart';
import 'package:pos_backend/models/stock/stock.dart';
import 'package:pos_backend/models/store/store.dart';
import 'package:uuid/uuid.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    .get => _getAllStock(context),
    _ => Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {'status': 'error', 'message': 'Method not allowed.'},
    ),
  };
}

Future<Response> _getAllStock(RequestContext context) async {
  final params = context.request.uri.queryParameters;

  final storeId = params['storeId'];
  final page = int.tryParse(params['page'] ?? '');
  final pageSize = int.tryParse(params['pageSize'] ?? '');

  if (storeId == null) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'status': 'error', 'message': 'Store Id parameter required.'},
    );
  }

  if (!Uuid.isValidUUID(fromString: storeId)) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'status': 'error', 'message': 'Store Id must be a uuid value.'},
    );
  }

  final stores = context.read<DataSource>().getRepository<Store>();
  final merchant = context.read<Merchant>();

  try {
    final store = await stores.findOneBy(
      where: StoreQuery(
        (s) => s.id.equals(storeId).and(s.merchantId.equals(merchant.id)),
      ),
    );
    if (store == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'status': 'error', 'message': 'Store not found.'},
      );
    }
  } on Exception {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Unable to verify store at the moment.',
      },
    );
  }

  final stockRepo = context.read<DataSource>().getRepository<Stock>();

  try {
    final stockPaginatedResult = await stockRepo.paginate(
      where: StockQuery((s) => s.storeId.equals(storeId)),
      page: page ?? 1,
      pageSize: pageSize ?? 10,
      maxPageSize: 100,
    );
    return Response.json(
      body: {
        'status': 'success',
        'paginatedResult': stockPaginatedResult,
      },
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
