import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:pos_backend/models/customer/customer.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {'status': 'error', 'message': 'Method not allowed.'},
    );
  }

  final customer = context.read<Customer>();

  return Response.json(
    body: {
      'status': 'success',
      'user': {
        'id': customer.id,
        'name': customer.name,
        'mobileNumber': customer.mobileNumber,
        'email': customer.email,
        'isActive': customer.isActive,
        'tokenVersion': customer.tokenVersion,
        'createdAt': customer.createdAt?.toIso8601String(),
        'updatedAt': customer.updatedAt?.toIso8601String(),
      },
    },
  );
}
