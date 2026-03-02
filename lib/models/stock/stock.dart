import 'package:loxia/loxia.dart';
import 'package:pos_backend/models/product/product.dart';
import 'package:pos_backend/models/store/store.dart';

part 'stock.g.dart';

/// Tracks per-store inventory for a product.
@EntityMeta(
  table: 'stock',
  uniqueConstraints: [
    UniqueConstraint(columns: ['product_id', 'store_id']),
  ],
)
class Stock extends Entity {
  /// Creates a stock record.
  Stock({
    required this.id,
    required this.quantity,
    required this.lowStockThreshold,
    this.product,
    this.store,
    this.createdAt,
    this.updatedAt,
  });

  /// Unique identifier for the stock entry.
  @PrimaryKey(uuid: true)
  final String id;

  /// Current quantity in stock.
  @Column()
  final int quantity;

  /// Threshold below which a low-stock alert is triggered.
  @Column()
  final int lowStockThreshold;

  /// Product this stock entry tracks.
  @ManyToOne(on: Product)
  @JoinColumn(name: 'product_id')
  final Product? product;

  /// Store this stock entry belongs to.
  @ManyToOne(on: Store)
  @JoinColumn(name: 'store_id')
  final Store? store;

  /// Timestamp when the stock record was created.
  @CreatedAt()
  DateTime? createdAt;

  /// Timestamp when the stock record was last updated.
  @UpdatedAt()
  DateTime? updatedAt;

  /// Entity descriptor used by Loxia for metadata and query operations.
  static EntityDescriptor<Stock, StockPartial> get entity =>
      $StockEntityDescriptor;
}
