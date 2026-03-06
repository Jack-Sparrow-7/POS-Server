import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:loxia/loxia.dart';
import 'package:pos_backend/models/category/category.dart';
import 'package:pos_backend/models/counter/counter.dart';
import 'package:pos_backend/models/merchant/merchant.dart';
import 'package:pos_backend/models/product/product.dart';
import 'package:pos_backend/models/stock/stock.dart';
import 'package:pos_backend/utils/db_error_matcher.dart';
import 'package:pos_backend/utils/json_body_parser.dart';
import 'package:pos_backend/validators/product_validators.dart';
import 'package:uuid/uuid.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return switch (context.request.method) {
    .get => _getProduct(context, id),
    .patch => _updateProduct(context, id),
    .delete => _deleteProduct(context, id),
    _ => Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {'status': 'error', 'message': 'Method not allowed.'},
    ),
  };
}

Future<Response> _getProduct(RequestContext context, String id) async {
  if (!Uuid.isValidUUID(fromString: id)) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'status': 'error', 'message': 'Id must be a uuid value.'},
    );
  }

  final products = context.read<DataSource>().getRepository<Product>();
  final merchant = context.read<Merchant>();

  try {
    final product = await products.findOneBy(
      where: ProductQuery(
        (p) => p.id.equals(id).and(p.store.merchantId.equals(merchant.id)),
      ),
    );
    if (product == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'status': 'error', 'message': 'Product not found.'},
      );
    }

    return Response.json(
      body: {'status': 'success', 'product': product},
    );
  } on Exception {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Unable to fetch product at the moment.',
      },
    );
  }
}

Future<Response> _updateProduct(RequestContext context, String id) async {
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

  final result = ProductValidators.updateSchema.tryParse(parsedBody.body!);

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

  final name = body['name'] as String?;
  final description = body['description'] as String?;
  final basePrice = (body['basePrice'] as num?)?.toInt();
  final sellingPrice = (body['sellingPrice'] as num?)?.toInt();
  final categoryId = body['categoryId'] as String?;
  final counterId = body['counterId'] as String?;
  final imageUrl = body['imageUrl'] as String?;
  final sku = body['sku'] as String?;
  final isActive = body['isActive'] as bool?;

  if (name == null &&
      description == null &&
      basePrice == null &&
      sellingPrice == null &&
      categoryId == null &&
      counterId == null &&
      imageUrl == null &&
      sku == null &&
      isActive == null) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {
        'status': 'error',
        'message': 'Request body must include at least one updatable field.',
      },
    );
  }

  final products = context.read<DataSource>().getRepository<Product>();
  final categories = context.read<DataSource>().getRepository<Category>();
  final counters = context.read<DataSource>().getRepository<Counter>();
  final merchant = context.read<Merchant>();
  Product? product;

  try {
    product = await products.findOneBy(
      where: ProductQuery(
        (p) => p.id.equals(id).and(p.store.merchantId.equals(merchant.id)),
      ),
    );
    if (product == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'status': 'error', 'message': 'Product not found.'},
      );
    }
  } on Exception {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Unable to verify product at the moment.',
      },
    );
  }
  if (categoryId != null) {
    try {
      final category = await categories.findOneBy(
        where: CategoryQuery(
          (c) => c.id
              .equals(categoryId)
              .and(c.store.merchantId.equals(merchant.id)),
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
  }

  if (counterId != null) {
    try {
      final counter = await counters.findOneBy(
        where: CounterQuery(
          (c) => c.id
              .equals(counterId)
              .and(c.store.merchantId.equals(merchant.id)),
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
  }

  try {
    final updatedProduct = await products.save(
      ProductPartial(
        id: id,
        name: name,
        description: description,
        basePrice: basePrice,
        sellingPrice: sellingPrice,
        categoryId: categoryId,
        counterId: counterId,
        imageUrl: imageUrl,
        sku: sku,
        isActive: isActive,
      ),
    );
    return Response.json(
      body: {
        'status': 'success',
        'product': updatedProduct,
        'message': 'Product updated successfully.',
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
        'message': 'Unable to update product at the moment.',
      },
    );
  }
}

Future<Response> _deleteProduct(RequestContext context, String id) async {
  if (!Uuid.isValidUUID(fromString: id)) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'status': 'error', 'message': 'Id must be a uuid value.'},
    );
  }

  final products = context.read<DataSource>().getRepository<Product>();
  final stocks = context.read<DataSource>().getRepository<Stock>();
  final merchant = context.read<Merchant>();
  Product? product;

  try {
    product = await products.findOneBy(
      where: ProductQuery(
        (p) => p.id.equals(id).and(p.store.merchantId.equals(merchant.id)),
      ),
    );
    if (product == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'status': 'error', 'message': 'Product not found.'},
      );
    }
  } on Exception {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Unable to verify product at the moment.',
      },
    );
  }
  try {
    final stock = await stocks.findOneBy(
      where: StockQuery(
        (s) =>
            s.productId.equals(id).and(s.store.merchantId.equals(merchant.id)),
      ),
    );
    if (stock != null) {
      await stocks.deleteEntity(stock);
    }

    await products.softDeleteEntity(product);

    return Response.json(
      body: {
        'status': 'success',
        'message': 'Product deleted successfully.',
      },
    );
  } on Exception {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Unable to delete product at the moment.',
      },
    );
  }
}
