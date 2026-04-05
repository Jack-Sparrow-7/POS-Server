import 'package:pos_server/models/category.dart';
import 'package:postgres/postgres.dart';

/// Repository for category persistence operations.
class CategoryRepository {
  /// Creates a new instance of [CategoryRepository].
  CategoryRepository({required Pool<String> pool}) : _pool = pool;

  final Pool<String> _pool;

  /// Returns all categories in a tenant, optionally filtered by store.
  Future<List<Category>> fetchAllForTenant({
    required String tenantId,
    String? storeId,
    bool? isActive,
  }) async {
    final result = await _pool.execute(
      Sql.named('''
        SELECT c.id,
               c.store_id,
               c.name,
               c.image_url,
               c.sort_order,
               c.is_active,
               c.created_at,
               c.updated_at
        FROM categories c
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

    return result.map((row) => Category.fromRow(row.toColumnMap())).toList();
  }

  /// Creates a category under a store owned by the given tenant.
  Future<Category?> createForTenant({
    required String tenantId,
    required String storeId,
    required String name,
    String? imageUrl,
    int sortOrder = 0,
  }) async {
    final result = await _pool.execute(
      Sql.named('''
        INSERT INTO categories (store_id, name, image_url, sort_order)
        SELECT s.id, @name, @imageUrl, @sortOrder
        FROM stores s
        WHERE s.id = @storeId
          AND s.tenant_id = @tenantId
        RETURNING id,
                  store_id,
                  name,
                  image_url,
                  sort_order,
                  is_active,
                  created_at,
                  updated_at
      '''),
      parameters: {
        'tenantId': tenantId,
        'storeId': storeId,
        'name': name,
        'imageUrl': imageUrl,
        'sortOrder': sortOrder,
      },
    );

    if (result.isEmpty) {
      return null;
    }

    return Category.fromRow(result.first.toColumnMap());
  }

  /// Finds a category by id scoped to a tenant.
  Future<Category?> findByIdForTenant({
    required String id,
    required String tenantId,
  }) async {
    final result = await _pool.execute(
      Sql.named('''
        SELECT c.id,
               c.store_id,
               c.name,
               c.image_url,
               c.sort_order,
               c.is_active,
               c.created_at,
               c.updated_at
        FROM categories c
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

    return Category.fromRow(result.first.toColumnMap());
  }

  /// Finds a category by id scoped to a tenant and store.
  Future<Category?> findByIdForStore({
    required String id,
    required String tenantId,
    required String storeId,
  }) async {
    final result = await _pool.execute(
      Sql.named('''
        SELECT c.id,
               c.store_id,
               c.name,
               c.image_url,
               c.sort_order,
               c.is_active,
               c.created_at,
               c.updated_at
        FROM categories c
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

    return Category.fromRow(result.first.toColumnMap());
  }

  /// Updates a category scoped to tenant and returns updated row.
  Future<Category?> updateForTenant({
    required String id,
    required String tenantId,
    required bool imageUrlProvided,
    String? name,
    String? imageUrl,
    int? sortOrder,
    bool? isActive,
  }) async {
    final result = await _pool.execute(
      Sql.named('''
        UPDATE categories c
        SET name = COALESCE(@name, c.name),
            image_url = CASE
              WHEN @imageUrlProvided THEN @imageUrl
              ELSE c.image_url
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
                  c.image_url,
                  c.sort_order,
                  c.is_active,
                  c.created_at,
                  c.updated_at
      '''),
      parameters: {
        'id': id,
        'tenantId': tenantId,
        'name': name,
        'imageUrl': imageUrl,
        'imageUrlProvided': imageUrlProvided,
        'sortOrder': sortOrder,
        'isActive': isActive,
      },
    );

    if (result.isEmpty) {
      return null;
    }

    return Category.fromRow(result.first.toColumnMap());
  }
}
