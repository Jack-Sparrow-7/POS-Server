import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:loxia/loxia.dart';
import 'package:pos_backend/enums/store_type.dart';
import 'package:pos_backend/models/merchant/merchant.dart';
import 'package:pos_backend/models/store/store.dart';
import 'package:pos_backend/utils/db_error_matcher.dart';
import 'package:pos_backend/utils/json_body_parser.dart';
import 'package:pos_backend/validators/store_validators.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    .post => _createStore(context),
    .get => _getAllStores(context),
    _ => Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {'status': 'error', 'message': 'Method not allowed.'},
    ),
  };
}

Future<Response> _createStore(RequestContext context) async {
  final parsedBody = await parseJsonObjectBody(context.request);
  if (parsedBody.errorResponse != null) {
    return parsedBody.errorResponse!;
  }

  final result = StoreValidators.createSchema.tryParse(parsedBody.body!);
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
  final email = body['email'] as String;
  final whatsappNumber = body['whatsappNumber'] as String?;
  final onlineOrderingEnabled = body['onlineOrderingEnabled'] as bool? ?? true;
  final type = StoreType.values.byName(body['type'] as String);

  final merchant = context.read<Merchant>();

  final stores = context.read<DataSource>().getRepository<Store>();

  try {
    final store = await stores.save(
      StorePartial(
        name: name,
        email: email,
        type: type,
        whatsappNumber: whatsappNumber,
        isActive: true,
        onlineOrderingEnabled: onlineOrderingEnabled,
        merchantId: merchant.id,
      ),
    );
    return Response.json(
      statusCode: HttpStatus.created,
      body: {
        'status': 'success',
        'store': {
          'id': store.id,
          'name': store.name,
          'email': store.email,
          'whatsappNumber': store.whatsappNumber,
          'type': store.type.name,
          'isActive': store.isActive,
          'onlineOrderingEnabled': store.onlineOrderingEnabled,
          'createdAt': store.createdAt?.toIso8601String(),
          'updatedAt': store.updatedAt?.toIso8601String(),
        },
        'message': 'Store created successfully.',
      },
    );
  } on Exception catch (e) {
    if (hasDbConstraint(e, [
      'uq_stores_name_merchant_id',
    ])) {
      return Response.json(
        statusCode: HttpStatus.conflict,
        body: {
          'status': 'error',
          'message': 'Store name already exists for this merchant.',
        },
      );
    }

    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Unable to create store at the moment.',
      },
    );
  }
}

Future<Response> _getAllStores(RequestContext context) async {
  final params = context.request.uri.queryParameters;
  final page = int.tryParse(params['page'] ?? '');
  final pageSize = int.tryParse(params['pageSize'] ?? '');

  final stores = context.read<DataSource>().getRepository<Store>();
  final merchant = context.read<Merchant>();

  try {
    final storesPaginatedResult = await stores.paginate(
      where: StoreQuery((s) => s.merchantId.equals(merchant.id)),
      page: page ?? 1,
      pageSize: pageSize ?? 10,
      maxPageSize: 100,
    );
    return Response.json(
      body: {
        'status': 'success',
        'paginatedResult': storesPaginatedResult,
      },
    );
  } on Exception {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Unable to fetch stores at the moment.',
      },
    );
  }
}
