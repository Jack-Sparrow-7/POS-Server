import 'package:pos_server/models/menu_item.dart';
import 'package:postgres/postgres.dart';

/// Repository for menu item persistence operations.
class MenuItemRepository {
  /// Creates a new instance of [MenuItemRepository].
  MenuItemRepository({required Pool<String> pool}) : _pool = pool;

  final Pool<String> _pool;

  /// Returns all menu items in a tenant, optionally filtered by store.
  Future<List<MenuItem>> fetchAllForTenant({
    required String tenantId,
    String? storeId,
    String? categoryId,
    String? counterId,
    bool? isAvailable,
  }) async {
    final result = await _pool.execute(
      Sql.named('''
        SELECT m.id,
               m.store_id,
               m.name,
               m.description,
               m.category_id,
               m.counter_id,
               m.cost_price,
               m.price,
               m.gst_percent,
               m.hsn_code,
               m.is_available,
               m.stock_count,
               m.track_stock,
               m.sort_order,
               m.image_url,
               m.created_at,
               m.updated_at
        FROM menu_items m
        INNER JOIN stores s ON s.id = m.store_id
        WHERE s.tenant_id = @tenantId
          AND (@storeId IS NULL OR m.store_id = @storeId)
          AND (@categoryId IS NULL OR m.category_id = @categoryId)
          AND (@counterId IS NULL OR m.counter_id = @counterId)
          AND (@isAvailable IS NULL OR m.is_available = @isAvailable)
        ORDER BY m.sort_order ASC, m.created_at DESC
      '''),
      parameters: {
        'tenantId': tenantId,
        'storeId': storeId,
        'categoryId': categoryId,
        'counterId': counterId,
        'isAvailable': isAvailable,
      },
    );

    return result.map((row) => MenuItem.fromRow(row.toColumnMap())).toList();
  }

  /// Creates a menu item under a store owned by the given tenant.
  Future<MenuItem?> createForTenant({
    required String tenantId,
    required String storeId,
    required String name,
    required num costPrice,
    required num price,
    required num gstPercent,
    String? description,
    String? categoryId,
    String? counterId,
    String? hsnCode,
    bool isAvailable = true,
    int? stockCount,
    bool trackStock = false,
    int sortOrder = 0,
    String? imageUrl,
  }) async {
    final result = await _pool.execute(
      Sql.named('''
        INSERT INTO menu_items (
          store_id,
          name,
          description,
          category_id,
          counter_id,
          cost_price,
          price,
          gst_percent,
          hsn_code,
          is_available,
          stock_count,
          track_stock,
          sort_order,
          image_url
        )
        SELECT s.id,
               @name,
               @description,
               @categoryId,
               @counterId,
               @costPrice,
               @price,
               @gstPercent,
               @hsnCode,
               @isAvailable,
               @stockCount,
               @trackStock,
               @sortOrder,
               @imageUrl
        FROM stores s
        WHERE s.id = @storeId
          AND s.tenant_id = @tenantId
          AND (
            @categoryId IS NULL
            OR EXISTS (
              SELECT 1
              FROM categories c
              WHERE c.id = @categoryId
                AND c.store_id = s.id
            )
          )
          AND (
            @counterId IS NULL
            OR EXISTS (
              SELECT 1
              FROM counters c
              WHERE c.id = @counterId
                AND c.store_id = s.id
            )
          )
        RETURNING id,
                  store_id,
                  name,
                  description,
                  category_id,
                  counter_id,
                  cost_price,
                  price,
                  gst_percent,
                  hsn_code,
                  is_available,
                  stock_count,
                  track_stock,
                  sort_order,
                  image_url,
                  created_at,
                  updated_at
      '''),
      parameters: {
        'tenantId': tenantId,
        'storeId': storeId,
        'name': name,
        'description': description,
        'categoryId': categoryId,
        'counterId': counterId,
        'costPrice': costPrice,
        'price': price,
        'gstPercent': gstPercent,
        'hsnCode': hsnCode,
        'isAvailable': isAvailable,
        'stockCount': stockCount,
        'trackStock': trackStock,
        'sortOrder': sortOrder,
        'imageUrl': imageUrl,
      },
    );

    if (result.isEmpty) {
      return null;
    }

    return MenuItem.fromRow(result.first.toColumnMap());
  }

  /// Finds a menu item by id scoped to a tenant.
  Future<MenuItem?> findByIdForTenant({
    required String id,
    required String tenantId,
  }) async {
    final result = await _pool.execute(
      Sql.named('''
        SELECT m.id,
               m.store_id,
               m.name,
               m.description,
               m.category_id,
               m.counter_id,
               m.cost_price,
               m.price,
               m.gst_percent,
               m.hsn_code,
               m.is_available,
               m.stock_count,
               m.track_stock,
               m.sort_order,
               m.image_url,
               m.created_at,
               m.updated_at
        FROM menu_items m
        INNER JOIN stores s ON s.id = m.store_id
        WHERE m.id = @id
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

    return MenuItem.fromRow(result.first.toColumnMap());
  }

  /// Finds a menu item by id scoped to a tenant and store.
  Future<MenuItem?> findByIdForStore({
    required String id,
    required String tenantId,
    required String storeId,
  }) async {
    final result = await _pool.execute(
      Sql.named('''
        SELECT m.id,
               m.store_id,
               m.name,
               m.description,
               m.category_id,
               m.counter_id,
               m.cost_price,
               m.price,
               m.gst_percent,
               m.hsn_code,
               m.is_available,
               m.stock_count,
               m.track_stock,
               m.sort_order,
               m.image_url,
               m.created_at,
               m.updated_at
        FROM menu_items m
        INNER JOIN stores s ON s.id = m.store_id
        WHERE m.id = @id
          AND s.tenant_id = @tenantId
          AND m.store_id = @storeId
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

    return MenuItem.fromRow(result.first.toColumnMap());
  }

  /// Updates a menu item scoped to tenant and returns updated row.
  Future<MenuItem?> updateForTenant({
    required String id,
    required String tenantId,
    required bool descriptionProvided,
    required bool categoryIdProvided,
    required bool counterIdProvided,
    required bool hsnCodeProvided,
    required bool stockCountProvided,
    required bool imageUrlProvided,
    String? name,
    String? description,
    String? categoryId,
    String? counterId,
    num? costPrice,
    num? price,
    num? gstPercent,
    String? hsnCode,
    bool? isAvailable,
    int? stockCount,
    bool? trackStock,
    int? sortOrder,
    String? imageUrl,
  }) async {
    final result = await _pool.execute(
      Sql.named('''
        UPDATE menu_items m
        SET name = COALESCE(@name, m.name),
            description = CASE
              WHEN @descriptionProvided THEN @description
              ELSE m.description
            END,
            category_id = CASE
              WHEN @categoryIdProvided THEN @categoryId
              ELSE m.category_id
            END,
            counter_id = CASE
              WHEN @counterIdProvided THEN @counterId
              ELSE m.counter_id
            END,
            cost_price = COALESCE(@costPrice, m.cost_price),
            price = COALESCE(@price, m.price),
            gst_percent = COALESCE(@gstPercent, m.gst_percent),
            hsn_code = CASE
              WHEN @hsnCodeProvided THEN @hsnCode
              ELSE m.hsn_code
            END,
            is_available = COALESCE(@isAvailable, m.is_available),
            stock_count = CASE
              WHEN @stockCountProvided THEN @stockCount
              ELSE m.stock_count
            END,
            track_stock = COALESCE(@trackStock, m.track_stock),
            sort_order = COALESCE(@sortOrder, m.sort_order),
            image_url = CASE
              WHEN @imageUrlProvided THEN @imageUrl
              ELSE m.image_url
            END,
            updated_at = NOW()
        FROM stores s
        WHERE m.id = @id
          AND s.id = m.store_id
          AND s.tenant_id = @tenantId
          AND (
            @categoryIdProvided = FALSE
            OR @categoryId IS NULL
            OR EXISTS (
              SELECT 1
              FROM categories c
              WHERE c.id = @categoryId
                AND c.store_id = s.id
            )
          )
          AND (
            @counterIdProvided = FALSE
            OR @counterId IS NULL
            OR EXISTS (
              SELECT 1
              FROM counters c
              WHERE c.id = @counterId
                AND c.store_id = s.id
            )
          )
        RETURNING m.id,
                  m.store_id,
                  m.name,
                  m.description,
                  m.category_id,
                  m.counter_id,
                  m.cost_price,
                  m.price,
                  m.gst_percent,
                  m.hsn_code,
                  m.is_available,
                  m.stock_count,
                  m.track_stock,
                  m.sort_order,
                  m.image_url,
                  m.created_at,
                  m.updated_at
      '''),
      parameters: {
        'id': id,
        'tenantId': tenantId,
        'name': name,
        'description': description,
        'descriptionProvided': descriptionProvided,
        'categoryId': categoryId,
        'categoryIdProvided': categoryIdProvided,
        'counterId': counterId,
        'counterIdProvided': counterIdProvided,
        'costPrice': costPrice,
        'price': price,
        'gstPercent': gstPercent,
        'hsnCode': hsnCode,
        'hsnCodeProvided': hsnCodeProvided,
        'isAvailable': isAvailable,
        'stockCount': stockCount,
        'stockCountProvided': stockCountProvided,
        'trackStock': trackStock,
        'sortOrder': sortOrder,
        'imageUrl': imageUrl,
        'imageUrlProvided': imageUrlProvided,
      },
    );

    if (result.isEmpty) {
      return null;
    }

    return MenuItem.fromRow(result.first.toColumnMap());
  }

  /// Deletes a menu item by id scoped to tenant.
  Future<bool> deleteByIdForTenant({
    required String id,
    required String tenantId,
  }) async {
    final result = await _pool.execute(
      Sql.named('''
        DELETE FROM menu_items m
        USING stores s
        WHERE m.id = @id
          AND s.id = m.store_id
          AND s.tenant_id = @tenantId
      '''),
      parameters: {
        'id': id,
        'tenantId': tenantId,
      },
    );

    return result.affectedRows > 0;
  }
}
