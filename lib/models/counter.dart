/// Represents a counter under a store.
class Counter {
  /// Creates a counter instance.
  Counter({
    required this.id,
    required this.storeId,
    required this.name,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.description,
  });

  /// Creates an instance from a database row.
  factory Counter.fromRow(Map<String, dynamic> row) => Counter(
    id: row['id'] as String,
    storeId: row['store_id'] as String,
    name: row['name'] as String,
    description: row['description'] as String?,
    isActive: row['is_active'] as bool,
    sortOrder: row['sort_order'] as int,
    createdAt: row['created_at'] as DateTime,
    updatedAt: row['updated_at'] as DateTime,
  );

  /// Counter identifier.
  final String id;

  /// Parent store identifier.
  final String storeId;

  /// Counter name.
  final String name;

  /// Optional counter description.
  final String? description;

  /// Whether counter is active.
  final bool isActive;

  /// Display sort order.
  final int sortOrder;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp.
  final DateTime updatedAt;

  /// Serializes counter for API responses.
  Map<String, dynamic> toMap() => {
    'id': id,
    'storeId': storeId,
    'name': name,
    'description': description,
    'isActive': isActive,
    'sortOrder': sortOrder,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
