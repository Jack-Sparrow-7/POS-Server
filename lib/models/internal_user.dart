import 'package:pos_server/enums/auth_role.dart';

/// Represents an internal user in the system, typically used for authentication
class InternalUser {
  /// Creates a new instance of [InternalUser].
  InternalUser({
    required this.id,
    required this.tenantId,
    required this.storeId,
    required this.email,
    required this.passwordHash,
    required this.role,
    required this.isActive,
  });

  /// Creates an [InternalUser] instance from a database row.
  factory InternalUser.fromRow(Map<String, dynamic> row) {
    return InternalUser(
      id: row['id'] as String,
      tenantId: row['tenant_id'] as String,
      storeId: row['store_id'] as String?,
      email: row['email'] as String,
      passwordHash: row['password_hash'] as String,
      role: switch (row['role']) {
        'merchant' => .merchant,
        'cashier' => .cashier,
        _ => throw ArgumentError('Unsupported role: ${row['role']}'),
      },
      isActive: row['is_active'] as bool,
    );
  }

  /// The unique identifier of the internal user.
  final String id;

  /// The tenant ID that this user belongs to.
  final String tenantId;

  /// The store ID that this user belongs to.
  final String? storeId;

  /// The email address of the internal user.
  final String email;

  /// The hashed password of the internal user.
  final String passwordHash;

  /// The role of the internal user, which determines their permissions.
  final AuthRole role;

  /// Indicates whether the internal user is active or not.
  final bool isActive;
}
