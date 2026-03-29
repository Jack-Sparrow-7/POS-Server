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

  /// Finds a tenant by its unique identifier.
  Future<Tenant?> findById(String id) async {
    final result = await _pool.execute(
      Sql.named('''
        SELECT id, name, email, phone, address, city, state, pincode,
               is_active, created_at, updated_at
        FROM tenants
        WHERE id = @id
        LIMIT 1
      '''),
      parameters: {'id': id},
    );

    if (result.isEmpty) {
      return null;
    }

    return Tenant.fromRow(result.first.toColumnMap());
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

  /// Updates a tenant and returns the updated row.
  Future<Tenant?> update({
    required String id,
    String? name,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? pincode,
    bool? isActive,
  }) async {
    final result = await _pool.execute(
      Sql.named('''
        UPDATE tenants
        SET name = COALESCE(@name, name),
            phone = COALESCE(@phone, phone),
            address = COALESCE(@address, address),
            city = COALESCE(@city, city),
            state = COALESCE(@state, state),
            pincode = COALESCE(@pincode, pincode),
            is_active = COALESCE(@isActive, is_active),
            updated_at = NOW()
        WHERE id = @id
        RETURNING id, name, email, phone, address, city, state, pincode,
                  is_active, created_at, updated_at
      '''),
      parameters: {
        'id': id,
        'name': name,
        'phone': phone,
        'address': address,
        'city': city,
        'state': state,
        'pincode': pincode,
        'isActive': isActive,
      },
    );

    if (result.isEmpty) {
      return null;
    }

    return Tenant.fromRow(result.first.toColumnMap());
  }
}
