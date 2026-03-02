import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

/// Result of attempting to parse a request JSON body as an object.
class JsonBodyParseResult {
  /// Creates a parse result with either [body] or [errorResponse].
  const JsonBodyParseResult({this.body, this.errorResponse});

  /// Parsed JSON object when parsing succeeds.
  final Map<String, dynamic>? body;

  /// Error response to return when parsing fails.
  final Response? errorResponse;
}

/// Parses the request body as a JSON object and validates `Content-Type`.
Future<JsonBodyParseResult> parseJsonObjectBody(Request request) async {
  final contentType = request.headers['content-type'] ?? '';
  if (!contentType.toLowerCase().contains('application/json')) {
    return JsonBodyParseResult(
      errorResponse: Response.json(
        statusCode: HttpStatus.unsupportedMediaType,
        body: {
          'status': 'error',
          'message': 'Content-Type must be application/json.',
        },
      ),
    );
  }

  try {
    final jsonBody = await request.json();
    if (jsonBody is! Map<String, dynamic>) {
      return JsonBodyParseResult(
        errorResponse: Response.json(
          statusCode: HttpStatus.badRequest,
          body: {
            'status': 'error',
            'message': 'Request body must be a JSON object.',
          },
        ),
      );
    }

    return JsonBodyParseResult(body: jsonBody);
  } on FormatException {
    return JsonBodyParseResult(
      errorResponse: Response.json(
        statusCode: HttpStatus.badRequest,
        body: {
          'status': 'error',
          'message': 'Invalid or empty JSON body. Send a valid JSON object.',
        },
      ),
    );
  }
}
