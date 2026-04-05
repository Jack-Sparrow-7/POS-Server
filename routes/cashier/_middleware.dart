import 'package:dart_frog/dart_frog.dart';
import 'package:pos_server/middlewares/auth_middleware.dart';

/// Restricts all cashier routes to authenticated cashiers.
Handler middleware(Handler handler) {
  return handler.use(cashierOnly());
}
