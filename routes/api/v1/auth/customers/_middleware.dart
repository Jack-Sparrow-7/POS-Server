import 'package:dart_frog/dart_frog.dart';
import 'package:pos_backend/middlewares/customer_auth_middleware.dart';

Handler middleware(Handler handler) {
  return handler.use(
    customerAuthMiddleware(
      applies: (context) async {
        final path = context.request.uri.path;
        return !(path.endsWith('/login') ||
            path.endsWith('/register') ||
            path.endsWith('/logout'));
      },
    ),
  );
}
