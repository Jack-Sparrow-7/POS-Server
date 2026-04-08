import 'package:dotenv/dotenv.dart';

/// Exposes environment-backed configuration values for the server.
class Env {
  const Env._();

  static final _env = DotEnv(includePlatformEnvironment: true)..load();
  static final Map<String, String?> _testOverrides = {};

  static String? _get(String key) {
    if (_testOverrides.containsKey(key)) {
      return _testOverrides[key];
    }
    return _env[key];
  }

  /// Overrides an environment variable value for tests.
  static void overrideForTesting(String key, String? value) {
    _testOverrides[key] = value;
  }

  /// Clears all environment variable overrides used by tests.
  static void clearTestOverrides() {
    _testOverrides.clear();
  }

  // Database
  /// Database host name or IP address.
  static String get dbHost =>
      _get('DB_HOST') ?? (throw Exception('DB_HOST not set'));

  /// Database port number.
  static int get dbPort => int.parse(_get('DB_PORT') ?? '5432');

  /// Database name.
  static String get dbName =>
      _get('DB_NAME') ?? (throw Exception('DB_NAME not set'));

  /// Database user name.
  static String get dbUser =>
      _get('DB_USER') ?? (throw Exception('DB_USER not set'));

  /// Database user password.
  static String get dbPassword =>
      _get('DB_PASSWORD') ?? (throw Exception('DB_PASSWORD not set'));

  // JWT
  /// Secret used to sign JWT tokens.
  static String get jwtSecret =>
      _get('JWT_SECRET') ?? (throw Exception('JWT_SECRET not set'));

  /// Access token lifetime in hours.
  static int get jwtExpiryHours => int.parse(_get('JWT_EXPIRY_HOURS') ?? '24');

  /// Refresh token lifetime in days.
  static int get jwtRefreshExpiryDays =>
      int.parse(_get('JWT_REFRESH_EXPIRY_DAYS') ?? '30');

  // Webhooks
  /// Optional shared secret for payment provider webhook verification.
  static String? get phonepeWebhookSecret => _get('PHONEPE_WEBHOOK_SECRET');

  /// Allowed webhook event timestamp skew in seconds.
  static int get phonepeWebhookMaxSkewSeconds =>
      int.parse(_get('PHONEPE_WEBHOOK_MAX_SKEW_SECONDS') ?? '300');
}
