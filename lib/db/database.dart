import 'package:pos_server/config/env.dart';
import 'package:postgres/postgres.dart';

/// Manages the shared PostgreSQL connection pool for the application.
class Database {
  Database._();

  /// Singleton database manager instance.
  static final Database instance = Database._();

  late final Pool<String> _pool;

  /// Initializes the PostgreSQL connection pool from environment settings.
  Future<void> init() async {
    _pool = Pool.withEndpoints(
      [
        Endpoint(
          host: Env.dbHost,
          port: Env.dbPort,
          database: Env.dbName,
          username: Env.dbUser,
          password: Env.dbPassword,
        ),
      ],
      settings: const PoolSettings(
        maxConnectionCount: 20,
        sslMode: SslMode.disable,
      ),
    );
  }

  /// Returns the initialized PostgreSQL connection pool.
  Pool<String> get pool => _pool;
}
