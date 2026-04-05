import 'package:pos_server/models/counter.dart';
import 'package:postgres/postgres.dart';

/// Repository for counter persistence operations.
class CounterRepository {
  /// Creates a new instance of [CounterRepository].
  CounterRepository({required Pool<String> pool}) : _pool = pool;

  final Pool<String> _pool;

  /// Returns all counters in a tenant, optionally filtered by store.
  Future<List<Counter>> fetchAllForTenant({
    required String tenantId,
    String? storeId,
    bool? isActive,
  }) async {
    final result = await _pool.execute(
      Sql.named('''
        SELECT c.id,
               c.store_id,
               c.name,
               c.description,
               c.is_active,
               c.sort_order,
               c.created_at,
               c.updated_at
        FROM counters c
        INNER JOIN stores s ON s.id = c.store_id
        WHERE s.tenant_id = @tenantId
          AND (@storeId IS NULL OR c.store_id = @storeId)
          AND (@isActive IS NULL OR c.is_active = @isActive)
        ORDER BY c.sort_order ASC, c.created_at DESC
      '''),
      parameters: {
        'tenantId': tenantId,
        'storeId': storeId,
        'isActive': isActive,
      },
    );

    return result.map((row) => Counter.fromRow(row.toColumnMap())).toList();
  }

  /// Creates a counter under a store owned by the given tenant.
  Future<Counter?> createForTenant({
    required String tenantId,
    required String storeId,
    required String name,
    String? description,
    int sortOrder = 0,
  }) async {
    final result = await _pool.execute(
      Sql.named('''
        INSERT INTO counters (store_id, name, description, sort_order)
        SELECT s.id, @name, @description, @sortOrder
        FROM stores s
        WHERE s.id = @storeId
          AND s.tenant_id = @tenantId
        RETURNING id,
                  store_id,
                  name,
                  description,
                  is_active,
                  sort_order,
                  created_at,
                  updated_at
      '''),
      parameters: {
        'tenantId': tenantId,
        'storeId': storeId,
        'name': name,
        'description': description,
        'sortOrder': sortOrder,
      },
    );

    if (result.isEmpty) {
      return null;
    }

    return Counter.fromRow(result.first.toColumnMap());
  }

  /// Finds a counter by id scoped to a tenant.
  Future<Counter?> findByIdForTenant({
    required String id,
    required String tenantId,
  }) async {
    final result = await _pool.execute(
      Sql.named('''
        SELECT c.id,
               c.store_id,
               c.name,
               c.description,
               c.is_active,
               c.sort_order,
               c.created_at,
               c.updated_at
        FROM counters c
        INNER JOIN stores s ON s.id = c.store_id
        WHERE c.id = @id
          AND s.tenant_id = @tenantId
        LIMIT 1
      '''),
      parameters: {
        'id': id,
        'tenantId': tenantId,
      },
    );

    if (result.isEmpty) {
      return null;
    }

    return Counter.fromRow(result.first.toColumnMap());
  }

  /// Finds a counter by id scoped to a tenant and store.
  Future<Counter?> findByIdForStore({
    required String id,
    required String tenantId,
    required String storeId,
  }) async {
    final result = await _pool.execute(
      Sql.named('''
        SELECT c.id,
               c.store_id,
               c.name,
               c.description,
               c.is_active,
               c.sort_order,
               c.created_at,
               c.updated_at
        FROM counters c
        INNER JOIN stores s ON s.id = c.store_id
        WHERE c.id = @id
          AND s.tenant_id = @tenantId
          AND c.store_id = @storeId
        LIMIT 1
      '''),
      parameters: {
        'id': id,
        'tenantId': tenantId,
        'storeId': storeId,
      },
    );

    if (result.isEmpty) {
      return null;
    }

    return Counter.fromRow(result.first.toColumnMap());
  }

  /// Updates a counter scoped to tenant and returns updated row.
  Future<Counter?> updateForTenant({
    required String id,
    required String tenantId,
    required bool descriptionProvided,
    String? name,
    String? description,
    int? sortOrder,
    bool? isActive,
  }) async {
    final result = await _pool.execute(
      Sql.named('''
        UPDATE counters c
        SET name = COALESCE(@name, c.name),
            description = CASE
              WHEN @descriptionProvided THEN @description
              ELSE c.description
            END,
            sort_order = COALESCE(@sortOrder, c.sort_order),
            is_active = COALESCE(@isActive, c.is_active),
            updated_at = NOW()
        FROM stores s
        WHERE c.id = @id
          AND s.id = c.store_id
          AND s.tenant_id = @tenantId
        RETURNING c.id,
                  c.store_id,
                  c.name,
                  c.description,
                  c.is_active,
                  c.sort_order,
                  c.created_at,
                  c.updated_at
      '''),
      parameters: {
        'id': id,
        'tenantId': tenantId,
        'name': name,
        'description': description,
        'descriptionProvided': descriptionProvided,
        'sortOrder': sortOrder,
        'isActive': isActive,
      },
    );

    if (result.isEmpty) {
      return null;
    }

    return Counter.fromRow(result.first.toColumnMap());
  }
}
