import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:loxia/loxia.dart';
import 'package:pos_backend/models/category/category.dart';
import 'package:pos_backend/models/counter/counter.dart';
import 'package:pos_backend/models/merchant/merchant.dart';
import 'package:pos_backend/models/product/product.dart';
import 'package:pos_backend/models/stock/stock.dart';
import 'package:pos_backend/models/store/store.dart';
import 'package:pos_backend/utils/db_error_matcher.dart';
import 'package:pos_backend/utils/json_body_parser.dart';
import 'package:pos_backend/validators/product_validators.dart';
import 'package:uuid/uuid.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    .post => _createProduct(context),
    .get => _getAllProducts(context),
    _ => Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {'status': 'error', 'message': 'Method not allowed.'},
    ),
  };
}

Future<Response> _createProduct(RequestContext context) async {
  final parsedBody = await parseJsonObjectBody(context.request);

  if (parsedBody.errorResponse != null) {
    return parsedBody.errorResponse!;
  }

  final result = ProductValidators.createSchema.tryParse(parsedBody.body!);

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

  final name = body['name'] as String;
  final description = body['description'] as String?;
  final basePrice = (body['basePrice'] as num).toInt();
  final sellingPrice = (body['sellingPrice'] as num).toInt();
  final storeId = body['storeId'] as String;
  final categoryId = body['categoryId'] as String;
  final counterId = body['counterId'] as String;
  final imageUrl = body['imageUrl'] as String?;
  final sku = body['sku'] as String?;

  final stores = context.read<DataSource>().getRepository<Store>();
  final categories = context.read<DataSource>().getRepository<Category>();
  final counters = context.read<DataSource>().getRepository<Counter>();
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

  try {
    final category = await categories.findOneBy(
      where: CategoryQuery(
        (c) => c.id.equals(categoryId).and(c.storeId.equals(storeId)),
      ),
    );
    if (category == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'status': 'error', 'message': 'Category not found for store.'},
      );
    }
  } on Exception {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Unable to verify category at the moment.',
      },
    );
  }

  try {
    final counter = await counters.findOneBy(
      where: CounterQuery(
        (c) => c.id.equals(counterId).and(c.storeId.equals(storeId)),
      ),
    );
    if (counter == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'status': 'error', 'message': 'Counter not found for store.'},
      );
    }
  } on Exception {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Unable to verify counter at the moment.',
      },
    );
  }

  final datasource = context.read<DataSource>();

  try {
    final (:stock, :product) = await datasource
        .transaction<({Stock stock, Product product})>(
          (tx) async {
            final products = tx.getRepository<Product>();
            final stocks = tx.getRepository<Stock>();

            final product = await products.save(
              ProductPartial(
                name: name,
                description: description,
                basePrice: basePrice,
                sellingPrice: sellingPrice,
                storeId: storeId,
                categoryId: categoryId,
                counterId: counterId,
                imageUrl: imageUrl,
                sku: sku,
                isActive: true,
              ),
            );

            final stock = await stocks.save(
              StockPartial(
                productId: product.id,
                storeId: storeId,
                quantity: 0,
                lowStockThreshold: 5,
              ),
            );
            return (
              stock: stock,
              product: product,
            );
          },
        );

    return Response.json(
      statusCode: HttpStatus.created,
      body: {
        'status': 'success',
        'product': product,
        'stock': stock,
        'message': 'Product created successfully.',
      },
    );
  } on Exception catch (e) {
    if (hasDbConstraint(e, ['uq_products_name_store_id'])) {
      return Response.json(
        statusCode: HttpStatus.conflict,
        body: {
          'status': 'error',
          'message': 'Product name already exists for this store.',
        },
      );
    }

    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Unable to create product at the moment.',
      },
    );
  }
}

Future<Response> _getAllProducts(RequestContext context) async {
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

  final products = context.read<DataSource>().getRepository<Product>();

  try {
    final productsPaginatedResult = await products.paginate(
      orderBy: [const OrderBy('name')],
      where: ProductQuery((p) => p.storeId.equals(storeId)),
      page: page ?? 1,
      pageSize: pageSize ?? 10,
      maxPageSize: 100,
    );
    return Response.json(
      body: {
        'status': 'success',
        'paginatedResult': productsPaginatedResult,
      },
    );
  } on Exception {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Unable to fetch products at the moment.',
      },
    );
  }
}
