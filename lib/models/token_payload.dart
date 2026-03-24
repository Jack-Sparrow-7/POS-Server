import 'package:pos_server/enums/auth_role.dart';

/// Serialized claims stored inside issued authentication tokens.
class TokenPayload {
  /// Creates a token payload from authenticated principal data.
  TokenPayload({
    required this.id,
    required this.role,
    required this.tenantId,
    required this.storeId,
  });

  /// Creates a token payload from a JSON map.
  factory TokenPayload.fromMap(Map<String, dynamic> map) => TokenPayload(
    id: map['sub'] as String,
    role: AuthRole.values.firstWhere((r) => r.name == map['role']),
    tenantId: map['tenant_id'] as String?,
    storeId: map['store_id'] as String?,
  );

  /// Unique identifier for the authenticated principal.
  final String id;

  /// Role assigned to the authenticated principal.
  final AuthRole role;

  /// Tenant identifier when the token is scoped to a tenant.
  final String? tenantId;

  /// Store identifier when the token is scoped to a store.
  final String? storeId;

  /// Converts this token payload into a JSON map.
  Map<String, dynamic> toMap() => {
    'sub': id,
    'role': role.name,
    if (tenantId != null) 'tenant_id': tenantId,
    if (storeId != null) 'store_id': storeId,
  };
}
