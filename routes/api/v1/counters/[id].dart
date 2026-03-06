import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:loxia/loxia.dart';
import 'package:pos_backend/models/counter/counter.dart';
import 'package:pos_backend/models/merchant/merchant.dart';
import 'package:pos_backend/models/product/product.dart';
import 'package:pos_backend/utils/db_error_matcher.dart';
import 'package:pos_backend/utils/json_body_parser.dart';
import 'package:pos_backend/validators/counter_validators.dart';
import 'package:uuid/uuid.dart';

Future<Response> onRequest(
  RequestContext context,
  String id,
) async {
  return switch (context.request.method) {
    .get => _getCounter(context, id),
    .put || .patch => _updateCounter(context, id),
    .delete => _deleteCounter(context, id),
    _ => Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {'status': 'error', 'message': 'Method not allowed.'},
    ),
  };
}

Future<Response> _getCounter(RequestContext context, String id) async {
  if (!Uuid.isValidUUID(fromString: id)) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'status': 'error', 'message': 'Invalid ID.'},
    );
  }

  final counters = context.read<DataSource>().getRepository<Counter>();
  final merchant = context.read<Merchant>();

  try {
    final counter = await counters.findOneBy(
      where: CounterQuery(
        (t) => t.id.equals(id).and(t.store.merchantId.equals(merchant.id)),
      ),
    );
    if (counter == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'status': 'error', 'message': 'Counter not found.'},
      );
    }
    return Response.json(
      body: {
        'status': 'success',
        'counter': counter,
      },
    );
  } on Exception {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Unable to fetch counter at the moment.',
      },
    );
  }
}

Future<Response> _updateCounter(RequestContext context, String id) async {
  if (!Uuid.isValidUUID(fromString: id)) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'status': 'error', 'message': 'Invalid ID.'},
    );
  }

  final parsedBody = await parseJsonObjectBody(context.request);
  if (parsedBody.errorResponse != null) {
    return parsedBody.errorResponse!;
  }

  final result = CounterValidators.updateSchema.tryParse(parsedBody.body!);
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
  final isActive = body['isActive'] as bool?;

  if (name == null && description == null && isActive == null) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {
        'status': 'error',
        'message': 'Provide at least one field to update.',
      },
    );
  }

  final counters = context.read<DataSource>().getRepository<Counter>();
  final merchant = context.read<Merchant>();

  try {
    final counter = await counters.findOneBy(
      where: CounterQuery(
        (t) => t.id.equals(id).and(t.store.merchantId.equals(merchant.id)),
      ),
    );
    if (counter == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'status': 'error', 'message': 'Counter not found.'},
      );
    }
  } on Exception {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Unable to check the counter right now.',
      },
    );
  }

  try {
    final updatedCounter = await counters.save(
      CounterPartial(
        id: id,
        name: name,
        description: description,
        isActive: isActive,
      ),
    );
    return Response.json(
      body: {
        'status': 'success',
        'counter': updatedCounter,
        'message': 'Counter updated successfully.',
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
        'message': 'Unable to update counter at the moment.',
      },
    );
  }
}

Future<Response> _deleteCounter(RequestContext context, String id) async {
  if (!Uuid.isValidUUID(fromString: id)) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'status': 'error', 'message': 'Invalid ID.'},
    );
  }

  final counters = context.read<DataSource>().getRepository<Counter>();
  final products = context.read<DataSource>().getRepository<Product>();
  final merchant = context.read<Merchant>();
  Counter? counter;

  try {
    counter = await counters.findOneBy(
      where: CounterQuery(
        (t) => t.id.equals(id).and(t.store.merchantId.equals(merchant.id)),
      ),
    );
    if (counter == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'status': 'error', 'message': 'Counter not found.'},
      );
    }
  } on Exception {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Unable to check the counter right now.',
      },
    );
  }

  try {
    final linkedProduct = await products.findOneBy(
      where: ProductQuery(
        (p) =>
            p.counterId.equals(id).and(p.store.merchantId.equals(merchant.id)),
      ),
    );
    if (linkedProduct != null) {
      return Response.json(
        statusCode: HttpStatus.conflict,
        body: {
          'status': 'error',
          'message': 'Counter cannot be deleted while products are linked.',
        },
      );
    }

    await counters.softDeleteEntity(counter);
    return Response.json(
      body: {
        'status': 'success',
        'message': 'Counter deleted successfully.',
      },
    );
  } on Exception {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Unable to delete counter at the moment.',
      },
    );
  }
}
