import 'package:dart_frog/dart_frog.dart';
import 'package:pos_backend/middlewares/merchant_auth_middleware.dart';

Handler middleware(Handler handler) {
  return handler.use(
    merchantAuthMiddleware(
      applies: (context) async {
        final path = context.request.uri.path;
        return !(path.endsWith('/login') ||
            path.endsWith('/register') ||
            path.endsWith('/refresh'));
      },
    ),
  );
}
