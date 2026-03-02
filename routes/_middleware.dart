import 'package:dart_frog/dart_frog.dart';
import 'package:pos_backend/middlewares/db_middleware.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart' as shelf;

Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(
        fromShelfMiddleware(
          shelf.corsHeaders(
            headers: {
              shelf.ACCESS_CONTROL_ALLOW_ORIGIN: 'http://localhost:*',
              shelf.ACCESS_CONTROL_ALLOW_CREDENTIALS: 'true',
            },
          ),
        ),
      )
      .use(dbMiddleware());
}
