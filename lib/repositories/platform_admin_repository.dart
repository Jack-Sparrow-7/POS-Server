import 'package:pos_server/models/platform_admin.dart';
import 'package:postgres/postgres.dart';

/// Repository for platform admin operations.
class PlatformAdminRepository {
  /// Creates a new instance of [PlatformAdminRepository].
  PlatformAdminRepository({required Pool<String> pool}) : _pool = pool;

  final Pool<String> _pool;

  /// Finds a platform admin by email.
  Future<PlatformAdmin?> findByEmail({required String email}) async {
    final result = await _pool.execute(
      Sql.named('''
        SELECT id, email, password_hash, name,
        is_active, created_at, updated_at FROM
        platform_admins WHERE email = @email LIMIT 1
      '''),
      parameters: {'email': email},
    );

    if (result.isEmpty) return null;

    return PlatformAdmin.fromRow(result.first.toColumnMap());
  }
}
