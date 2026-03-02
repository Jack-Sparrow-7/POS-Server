import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:loxia/loxia.dart';
import 'package:pos_backend/models/counter/counter.dart';
import 'package:pos_backend/models/merchant/merchant.dart';
import 'package:pos_backend/models/store/store.dart';
import 'package:pos_backend/utils/db_error_matcher.dart';
import 'package:pos_backend/utils/json_body_parser.dart';
import 'package:pos_backend/validators/counter_validators.dart';
import 'package:uuid/uuid.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    .post => _createCounter(context),
    .get => _getAllCounters(context),
    _ => Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {'status': 'error', 'message': 'Method not allowed.'},
    ),
  };
}

Future<Response> _createCounter(RequestContext context) async {
  final parsedBody = await parseJsonObjectBody(context.request);

  if (parsedBody.errorResponse != null) {
    return parsedBody.errorResponse!;
  }

  final result = CounterValidators.createSchema.tryParse(parsedBody.body!);

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

  final counters = context.read<DataSource>().getRepository<Counter>();

  try {
    final counter = await counters.save(
      CounterPartial(
        name: name,
        description: description,
        storeId: storeId,
        isActive: false,
      ),
    );
    return Response.json(
      statusCode: HttpStatus.created,
      body: {
        'status': 'success',
        'counter': counter,
        'message': 'Counter created successfully.',
      },
    );
  } on Exception catch (e) {
    if (hasDbConstraint(e, ['uq_counters_name_store_id'])) {
      return Response.json(
        statusCode: HttpStatus.conflict,
        body: {
          'status': 'error',
          'message': 'Counter name already exists for this store.',
        },
      );
    }

    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Unable to create counter at the moment.',
      },
    );
  }
}

Future<Response> _getAllCounters(RequestContext context) async {
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

  final counters = context.read<DataSource>().getRepository<Counter>();

  try {
    final countersPaginatedResult = await counters.paginate(
      orderBy: [const OrderBy('name')],
      where: CounterQuery((t) => t.storeId.equals(storeId)),
      page: page ?? 1,
      pageSize: pageSize ?? 10,
      maxPageSize: 100,
    );
    return Response.json(
      body: {
        'status': 'success',
        'paginatedResult': countersPaginatedResult,
      },
    );
  } on Exception {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Unable to fetch counters at the moment.',
      },
    );
  }
}
