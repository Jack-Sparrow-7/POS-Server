import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:loxia/loxia.dart';
import 'package:pos_backend/enums/store_type.dart';
import 'package:pos_backend/models/merchant/merchant.dart';
import 'package:pos_backend/models/store/store.dart';
import 'package:pos_backend/utils/db_error_matcher.dart';
import 'package:pos_backend/utils/json_body_parser.dart';
import 'package:pos_backend/validators/store_validators.dart';
import 'package:uuid/uuid.dart';

Future<Response> onRequest(
  RequestContext context,
  String id,
) async {
  return switch (context.request.method) {
    .get => _getStore(context, id),
    .patch || .put => _updateStore(context, id),
    _ => Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {'status': 'error', 'message': 'Method not allowed.'},
    ),
  };
}

Future<Response> _getStore(RequestContext context, String id) async {
  if (!Uuid.isValidUUID(fromString: id)) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'status': 'error', 'message': 'Id must be a uuid value.'},
    );
  }

  final stores = context.read<DataSource>().getRepository<Store>();
  final merchant = context.read<Merchant>();

  try {
    final store = await stores.findOneBy(
      where: StoreQuery(
        (s) => s.id.equals(id).and(s.merchantId.equals(merchant.id)),
      ),
    );
    if (store == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'status': 'error', 'message': 'Store not found.'},
      );
    }

    return Response.json(
      body: {
        'status': 'success',
        'store': {
          'id': store.id,
          'name': store.name,
          'email': store.email,
          'whatsappNumber': store.whatsappNumber,
          'type': store.type.name,
          'createdAt': store.createdAt?.toIso8601String(),
          'updatedAt': store.updatedAt?.toIso8601String(),
        },
      },
    );
  } on Exception {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Unable to fetch store at the moment.',
      },
    );
  }
}

Future<Response> _updateStore(RequestContext context, String id) async {
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

  final result = StoreValidators.updateSchema.tryParse(parsedBody.body!);
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
  final email = body['email'] as String?;
  final typeName = body['type'] as String?;
  final type = typeName != null ? StoreType.values.byName(typeName) : null;
  final whatsappNumber = body['whatsappNumber'] as String?;

  if (name == null && email == null && type == null && whatsappNumber == null) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {
        'status': 'error',
        'message': 'Request body must include at least one updatable field.',
      },
    );
  }

  final stores = context.read<DataSource>().getRepository<Store>();
  final merchant = context.read<Merchant>();

  try {
    final store = await stores.findOneBy(
      where: StoreQuery(
        (s) => s.id.equals(id).and(s.merchantId.equals(merchant.id)),
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
        'message': 'Unable to process update at the moment.',
      },
    );
  }

  try {
    final updatedStore = await stores.save(
      StorePartial(
        id: id,
        name: name,
        email: email,
        whatsappNumber: whatsappNumber,
        type: type,
      ),
    );
    return Response.json(
      body: {
        'status': 'success',
        'store': {
          'id': updatedStore.id,
          'name': updatedStore.name,
          'email': updatedStore.email,
          'whatsappNumber': updatedStore.whatsappNumber,
          'type': updatedStore.type.name,
          'createdAt': updatedStore.createdAt?.toIso8601String(),
          'updatedAt': updatedStore.updatedAt?.toIso8601String(),
        },
        'message': 'Store updated successfully.',
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
        'message': 'Unable to update store at the moment.',
      },
    );
  }
}
