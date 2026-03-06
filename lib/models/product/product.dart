import 'package:loxia/loxia.dart';
import 'package:pos_backend/models/category/category.dart';
import 'package:pos_backend/models/counter/counter.dart';
import 'package:pos_backend/models/stock/stock.dart';
import 'package:pos_backend/models/store/store.dart';

part 'product.g.dart';

/// Represents a sellable product within a store.
@EntityMeta(
  table: 'products',
  uniqueConstraints: [
    UniqueConstraint(columns: ['name', 'store_id']),
  ],
)
class Product extends Entity {
  /// Creates a product record.
  Product({
    required this.id,
    required this.name,
    required this.basePrice,
    required this.sellingPrice,
    this.isActive = true,
    this.description,
    this.sku,
    this.imageUrl,
    this.store,
    this.category,
    this.counter,
    this.stock,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  /// Unique identifier for the product.
  @PrimaryKey(uuid: true)
  final String id;

  /// Product display name.
  @Column()
  final String name;

  /// Optional product description.
  @Column()
  final String? description;

  /// Cost price of the product in paise (smallest currency unit).
  @Column()
  final int basePrice;

  /// Retail price of the product in paise (smallest currency unit).
  @Column()
  final int sellingPrice;

  /// Optional SKU / barcode identifier.
  @Column()
  final String? sku;

  /// Optional URL to the product image.
  @Column()
  final String? imageUrl;

  /// Whether this product is currently active.
  @Column()
  final bool isActive;

  /// Store that owns this product.
  @ManyToOne(on: Store)
  @JoinColumn(name: 'store_id')
  final Store? store;

  /// Category this product belongs to.
  @ManyToOne(on: Category)
  @JoinColumn(name: 'category_id')
  final Category? category;

  /// Counter this product is served from.
  @ManyToOne(on: Counter)
  @JoinColumn(name: 'counter_id')
  final Counter? counter;

  /// Stock row linked to this product.
  @OneToOne(on: Stock, mappedBy: 'product')
  final Stock? stock;

  /// Timestamp when the product was created.
  @CreatedAt()
  DateTime? createdAt;

  /// Timestamp when the product was last updated.
  @UpdatedAt()
  DateTime? updatedAt;

  /// Timestamp when the product was soft-deleted.
  @DeletedAt()
  DateTime? deletedAt;

  /// Entity descriptor used by Loxia for metadata and query operations.
  static EntityDescriptor<Product, ProductPartial> get entity =>
      $ProductEntityDescriptor;
}
