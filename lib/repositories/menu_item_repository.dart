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
  }) async {
    final Result result;

    if (storeId == null) {
      result = await _pool.execute(
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
          ORDER BY m.sort_order ASC, m.created_at DESC
        '''),
        parameters: {'tenantId': tenantId},
      );
    } else {
      result = await _pool.execute(
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
            AND m.store_id = @storeId
          ORDER BY m.sort_order ASC, m.created_at DESC
        '''),
        parameters: {
          'tenantId': tenantId,
          'storeId': storeId,
        },
      );
    }

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
}
