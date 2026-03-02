import 'dart:io';

import 'package:dotenv/dotenv.dart' as dotenv;

/// Provides access to environment configuration loaded from `.env` files.
class Env {
  Env._();
  static late final dotenv.DotEnv _env;

  /// Loads environment variables from `.env.<APP_ENV>`.
  ///
  /// Falls back to `.env.dev` when `APP_ENV` is not set.
  static void load() {
    final appEnv = Platform.environment['APP_ENV'] ?? 'dev';
    _env = dotenv.DotEnv(includePlatformEnvironment: true)
      ..load(['.env.$appEnv']);
  }

  /// Returns `true` when the current app environment is production.
  static bool get isProd => _env['APP_ENV'] == 'prod';

  /// Database host name or address.
  static String get dbHost => _env['DB_HOST']!;

  /// Database port number.
  static int get dbPort => int.parse(_env['DB_PORT']!);

  /// Database name.
  static String get dbName => _env['DB_NAME']!;

  /// Database user name.
  static String get dbUser => _env['DB_USER']!;

  /// Database password.
  static String get dbPassword => _env['DB_PASSWORD']!;

  /// JWT Secret
  static String get jwtSecret => _env['JWT_SECRET']!;

  /// Default JWT token validity duration.
  static Duration jwtExpiry = const Duration(days: 7);
}
