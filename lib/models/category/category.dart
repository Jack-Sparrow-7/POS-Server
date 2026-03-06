import 'package:loxia/loxia.dart';
import 'package:pos_backend/models/store/store.dart';

part 'category.g.dart';

/// Represents a product/service category under a store.
@EntityMeta(
  table: 'categories',
  uniqueConstraints: [
    UniqueConstraint(columns: ['name', 'store_id']),
  ],
)
class Category extends Entity {
  /// Creates a category record.
  Category({
    required this.id,
    required this.name,
    required this.description,
    this.isActive = true,
    this.store,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.imageUrl,
  });

  /// Unique identifier for the category.
  @PrimaryKey(uuid: true)
  final String id;

  /// Category display name.
  @Column()
  final String name;

  /// Optional category description.
  @Column()
  final String? description;

  /// Optional URL to the category image.
  @Column()
  final String? imageUrl;

  /// Whether this category is currently active.
  @Column()
  final bool isActive;

  /// Store that owns this category.
  @ManyToOne(on: Store)
  @JoinColumn(name: 'store_id')
  final Store? store;

  /// Timestamp when the category was created.
  @CreatedAt()
  DateTime? createdAt;

  /// Timestamp when the category was last updated.
  @UpdatedAt()
  DateTime? updatedAt;

  /// Timestamp when the category was soft-deleted.
  @DeletedAt()
  DateTime? deletedAt;

  /// Entity descriptor used by Loxia for metadata and query operations.
  static EntityDescriptor<Category, CategoryPartial> get entity =>
      $CategoryEntityDescriptor;
}
