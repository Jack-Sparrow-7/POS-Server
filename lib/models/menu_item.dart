/// Represents a menu item under a store.
class MenuItem {
  /// Creates a menu item instance.
  MenuItem({
    required this.id,
    required this.storeId,
    required this.name,
    required this.costPrice,
    required this.price,
    required this.gstPercent,
    required this.isAvailable,
    required this.trackStock,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.categoryId,
    this.counterId,
    this.hsnCode,
    this.stockCount,
    this.imageUrl,
  });

  /// Creates an instance from a database row.
  factory MenuItem.fromRow(Map<String, dynamic> row) => MenuItem(
    id: row['id'] as String,
    storeId: row['store_id'] as String,
    name: row['name'] as String,
    description: row['description'] as String?,
    categoryId: row['category_id'] as String?,
    counterId: row['counter_id'] as String?,
    costPrice: row['cost_price'] as num,
    price: row['price'] as num,
    gstPercent: row['gst_percent'] as num,
    hsnCode: row['hsn_code'] as String?,
    isAvailable: row['is_available'] as bool,
    stockCount: row['stock_count'] as int?,
    trackStock: row['track_stock'] as bool,
    sortOrder: row['sort_order'] as int,
    imageUrl: row['image_url'] as String?,
    createdAt: row['created_at'] as DateTime,
    updatedAt: row['updated_at'] as DateTime,
  );

  /// Menu item identifier.
  final String id;

  /// Parent store identifier.
  final String storeId;

  /// Menu item name.
  final String name;

  /// Optional menu item description.
  final String? description;

  /// Optional category identifier.
  final String? categoryId;

  /// Optional counter identifier.
  final String? counterId;

  /// Menu item cost price.
  final num costPrice;

  /// Menu item selling price.
  final num price;

  /// GST percentage applied to this item.
  final num gstPercent;

  /// Optional HSN code.
  final String? hsnCode;

  /// Whether menu item is available.
  final bool isAvailable;

  /// Optional current stock count.
  final int? stockCount;

  /// Whether stock is tracked.
  final bool trackStock;

  /// Display sort order.
  final int sortOrder;

  /// Optional image URL.
  final String? imageUrl;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp.
  final DateTime updatedAt;

  /// Serializes menu item for API responses.
  Map<String, dynamic> toMap() => {
    'id': id,
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
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
