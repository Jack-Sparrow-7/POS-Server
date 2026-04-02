/// Represents a category under a store.
class Category {
  /// Creates a category instance.
  Category({
    required this.id,
    required this.storeId,
    required this.name,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
  });

  /// Creates an instance from a database row.
  factory Category.fromRow(Map<String, dynamic> row) => Category(
    id: row['id'] as String,
    storeId: row['store_id'] as String,
    name: row['name'] as String,
    imageUrl: row['image_url'] as String?,
    sortOrder: row['sort_order'] as int,
    isActive: row['is_active'] as bool,
    createdAt: row['created_at'] as DateTime,
    updatedAt: row['updated_at'] as DateTime,
  );

  /// Category identifier.
  final String id;

  /// Parent store identifier.
  final String storeId;

  /// Category name.
  final String name;

  /// Optional image URL.
  final String? imageUrl;

  /// Display sort order.
  final int sortOrder;

  /// Whether category is active.
  final bool isActive;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp.
  final DateTime updatedAt;

  /// Serializes category for API responses.
  Map<String, dynamic> toMap() => {
    'id': id,
    'storeId': storeId,
    'name': name,
    'imageUrl': imageUrl,
    'sortOrder': sortOrder,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
