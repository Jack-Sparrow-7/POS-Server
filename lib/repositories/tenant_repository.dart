import 'package:pos_server/models/tenant.dart';
import 'package:postgres/postgres.dart';

/// Repository for tenant persistence operations.
class TenantRepository {
  /// Creates a new instance of [TenantRepository].
  TenantRepository({required Pool<String> pool}) : _pool = pool;

  final Pool<String> _pool;

  /// Returns all tenants ordered by newest first.
  Future<List<Tenant>> fetchAll() async {
    final result = await _pool.execute(
      Sql.named('''
        SELECT id, name, email, phone, address, city, state, pincode,
               is_active, created_at, updated_at
        FROM tenants
        ORDER BY created_at DESC
      '''),
    );

    return result.map((row) => Tenant.fromRow(row.toColumnMap())).toList();
  }

  /// Creates a tenant and returns the inserted row.
  Future<Tenant> create({
    required String name,
    required String email,
    required String phone,
    String? address,
    String? city,
    String? state,
    String? pincode,
  }) async {
    final result = await _pool.execute(
      Sql.named('''
        INSERT INTO tenants (name, email, phone, address, city, state, pincode)
        VALUES (@name, @email, @phone, @address, @city, @state, @pincode)
        RETURNING id, name, email, phone, address, city, state, pincode,
                  is_active, created_at, updated_at
      '''),
      parameters: {
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'city': city,
        'state': state,
        'pincode': pincode,
      },
    );

    return Tenant.fromRow(result.first.toColumnMap());
  }
}
