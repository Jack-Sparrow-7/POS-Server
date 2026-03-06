import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:loxia/loxia.dart';
import 'package:pos_backend/models/category/category.dart';
import 'package:pos_backend/models/merchant/merchant.dart';
import 'package:pos_backend/models/product/product.dart';
import 'package:pos_backend/utils/db_error_matcher.dart';
import 'package:pos_backend/utils/json_body_parser.dart';
import 'package:pos_backend/validators/category_validators.dart';
import 'package:uuid/uuid.dart';

Future<Response> onRequest(
  RequestContext context,
  String id,
) async {
  return switch (context.request.method) {
    .get => _getCategory(context, id),
    .put || .patch => _updateCategory(context, id),
    .delete => _deleteCategory(context, id),
    _ => Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {'status': 'error', 'message': 'Method not allowed.'},
    ),
  };
}

Future<Response> _getCategory(RequestContext context, String id) async {
  if (!Uuid.isValidUUID(fromString: id)) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'status': 'error', 'message': 'Invalid ID.'},
    );
  }

  final categories = context.read<DataSource>().getRepository<Category>();
  final merchant = context.read<Merchant>();

  try {
    final category = await categories.findOneBy(
      where: CategoryQuery(
        (t) => t.id.equals(id).and(t.store.merchantId.equals(merchant.id)),
      ),
    );
    if (category == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'status': 'error', 'message': 'Category not found.'},
      );
    }
    return Response.json(
      body: {
        'status': 'success',
        'category': category,
      },
    );
  } on Exception {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Unable to fetch category at the moment.',
      },
    );
  }
}

Future<Response> _updateCategory(RequestContext context, String id) async {
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

  final result = CategoryValidators.updateSchema.tryParse(parsedBody.body!);
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
  final imageUrl = body['imageUrl'] as String?;

  if (name == null &&
      description == null &&
      isActive == null &&
      imageUrl == null) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {
        'status': 'error',
        'message': 'Provide at least one field to update.',
      },
    );
  }

  final categories = context.read<DataSource>().getRepository<Category>();
  final merchant = context.read<Merchant>();

  try {
    final category = await categories.findOneBy(
      where: CategoryQuery(
        (t) => t.id.equals(id).and(t.store.merchantId.equals(merchant.id)),
      ),
    );
    if (category == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'status': 'error', 'message': 'Category not found.'},
      );
    }
  } on Exception {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Unable to check the category right now.',
      },
    );
  }

  try {
    final updatedCategory = await categories.save(
      CategoryPartial(
        id: id,
        name: name,
        description: description,
        isActive: isActive,
        imageUrl: imageUrl,
      ),
    );
    return Response.json(
      body: {
        'status': 'success',
        'category': updatedCategory,
        'message': 'Category updated successfully.',
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
        'message': 'Unable to update category at the moment.',
      },
    );
  }
}

Future<Response> _deleteCategory(RequestContext context, String id) async {
  if (!Uuid.isValidUUID(fromString: id)) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'status': 'error', 'message': 'Invalid ID.'},
    );
  }

  final categories = context.read<DataSource>().getRepository<Category>();
  final products = context.read<DataSource>().getRepository<Product>();
  final merchant = context.read<Merchant>();
  Category? category;

  try {
    category = await categories.findOneBy(
      where: CategoryQuery(
        (t) => t.id.equals(id).and(t.store.merchantId.equals(merchant.id)),
      ),
    );
    if (category == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'status': 'error', 'message': 'Category not found.'},
      );
    }
  } on Exception {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Unable to check the category right now.',
      },
    );
  }

  try {
    final linkedProduct = await products.findOneBy(
      where: ProductQuery(
        (p) =>
            p.categoryId.equals(id).and(p.store.merchantId.equals(merchant.id)),
      ),
    );
    if (linkedProduct != null) {
      return Response.json(
        statusCode: HttpStatus.conflict,
        body: {
          'status': 'error',
          'message': 'Category cannot be deleted while products are linked.',
        },
      );
    }

    await categories.softDeleteEntity(category);
    return Response.json(
      body: {
        'status': 'success',
        'message': 'Category deleted successfully.',
      },
    );
  } on Exception {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'Unable to delete category at the moment.',
      },
    );
  }
}
