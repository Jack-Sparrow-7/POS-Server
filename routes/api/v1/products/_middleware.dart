import 'package:dart_frog/dart_frog.dart';
import 'package:pos_backend/middlewares/merchant_terminal_auth_middleware.dart';

/// Applies merchant-terminal authentication to product routes.
Handler middleware(Handler handler) {
  return handler.use(merchantTerminalAuthMiddleware());
}
