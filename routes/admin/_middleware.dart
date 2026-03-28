import 'package:dart_frog/dart_frog.dart';
import 'package:pos_server/middlewares/auth_middleware.dart';

/// Restricts all admin routes to authenticated super administrators.
Handler middleware(Handler handler) {
  return handler.use(superAdminOnly());
}
