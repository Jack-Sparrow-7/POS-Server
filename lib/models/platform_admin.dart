/// Represents a platform-wide administrator with full system access.
class PlatformAdmin {
  /// Creates a platform admin instance.
  PlatformAdmin({
    required this.id,
    required this.email,
    required this.passwordHash,
    required this.name,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates an instance from a database row.
  factory PlatformAdmin.fromRow(Map<String, dynamic> row) => PlatformAdmin(
    id: row['id'] as String,
    email: row['email'] as String,
    passwordHash: row['password_hash'] as String,
    name: row['name'] as String,
    isActive: row['is_active'] as bool,
    createdAt: row['created_at'] as DateTime,
    updatedAt: row['updated_at'] as DateTime,
  );

  /// Unique identifier for this admin.
  final String id;

  /// Email address used for authentication.
  final String email;

  /// Bcrypt hashed password.
  final String passwordHash;

  /// Display name of the admin.
  final String name;

  /// Whether this admin account is active.
  final bool isActive;

  /// Timestamp when the admin was created.
  final DateTime createdAt;

  /// Timestamp when the admin was last updated.
  final DateTime updatedAt;
}
