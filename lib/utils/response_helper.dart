import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

/// A helper class for creating standardized API responses.
class ResponseHelper {
  const ResponseHelper._();

  /// Creates a standardized success response.
  static Response success({
    int statusCode = HttpStatus.ok,
    String message = 'Success',
    Object? data,
    Map<String, Object>? meta,
  }) {
    return Response.json(
      statusCode: statusCode,
      body: {
        'success': true,
        'message': message,
        if (data != null) 'data': data,
        if (meta != null) 'meta': meta,
      },
    );
  }

  /// Creates a standardized error response.
  static Response problem({
    required int statusCode,
    required String code,
    required String message,
    Object? details,
  }) {
    return Response.json(
      statusCode: statusCode,
      body: {
        'success': false,
        'error': {
          'code': code,
          'message': message,
          if (details != null) 'details': details,
        },
      },
    );
  }
}
