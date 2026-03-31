import 'package:pos_server/models/internal_user.dart';
import 'package:postgres/postgres.dart';

/// A repository for managing internal users (e.g., administrators).
class InternalUserRepository {
  /// Creates a new instance of [InternalUserRepository] 
  /// with the given PostgreSQL connection pool.
  InternalUserRepository({required Pool<String> pool}) : _pool = pool;

  final Pool<String> _pool;

  /// Finds an internal user by their email address.
  Future<InternalUser?> findByEmail({required String email}) async {
    final result = await _pool.execute(
      Sql.named('''
        SELECT
          id,
          tenant_id,
          store_id,
          name,
          email,
          password_hash,
          role,
          is_active,
          last_login_at,
          created_at,
          updated_at
        FROM users WHERE email = @email AND role IN ('merchant', 'cashier') LIMIT 1;
      '''),
      parameters: {'email': email},
    );

    if (result.isEmpty) {
      return null;
    }

    return InternalUser.fromRow(result.first.toColumnMap());
  }
}
