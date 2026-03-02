import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:loxia/loxia.dart';
import 'package:pos_backend/models/category/category.dart';
import 'package:pos_backend/models/merchant/merchant.dart';
import 'package:pos_backend/models/store/store.dart';
import 'package:pos_backend/utils/db_error_matcher.dart';
import 'package:pos_backend/utils/json_body_parser.dart';
import 'package:pos_backend/validators/category_validators.dart';
import 'package:uuid/uuid.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    .post => _createCategory(context),
    .get => _getAllCategories(context),
    _ => Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {'status': 'error', 'message': 'Method not allowed.'},
    ),
  };
}

Future<Response> _createCategory(RequestContext context) async {
  final parsedBody = await parseJsonObjectBody(context.request);

  if (parsedBody.errorResponse != null) {
    return parsedBody.errorResponse!;
  }

  final result = CategoryValidators.createSchema.tryParse(parsedBody.body!);

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
  final storeId = body['storeId'] as String;
  final imageUrl = body['imageUrl'] as String?;

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

  final categories = context.read<DataSource>().getRepository<Category>();

  try {
    final category = await categories.save(
      CategoryPartial(
        name: name,
        description: description,
        storeId: storeId,
        isActive: false,
        imageUrl: imageUrl,
      ),
    );
    return Response.json(
      statusCode: HttpStatus.created,
      body: {
        'status': 'success',
        'category': category,
        'message': 'Category created successfully.',
      },
    );
  } on Exception catch (e) {
    if (hasDbConstraint(e, ['uq_categories_name_store_id'])) {
      return Response.json(
        statusCode: HttpStatus.conflict,
        body: {
          'status': 'error',
          'message': 'Category name already exists for this store.',
        },
      );
    }

    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Unable to create category at the moment.',
      },
    );
  }
}

Future<Response> _getAllCategories(RequestContext context) async {
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

  final categories = context.read<DataSource>().getRepository<Category>();

  try {
    final categoriesPaginatedResult = await categories.paginate(
      orderBy: [const OrderBy('name')],
      where: CategoryQuery((t) => t.storeId.equals(storeId)),
      page: page ?? 1,
      pageSize: pageSize ?? 10,
      maxPageSize: 100,
    );
    return Response.json(
      body: {
        'status': 'success',
        'paginatedResult': categoriesPaginatedResult,
      },
    );
  } on Exception {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Unable to fetch categories at the moment.',
      },
    );
  }
}
