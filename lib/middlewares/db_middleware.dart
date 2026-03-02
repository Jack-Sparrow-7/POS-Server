import 'package:dart_frog/dart_frog.dart';
import 'package:loxia/loxia.dart';
import 'package:pos_backend/config/database.dart';

/// Provides the shared [DataSource] to each request context.
Middleware dbMiddleware() {
  return provider<DataSource>(
    (context) => dataSource,
  );
}
