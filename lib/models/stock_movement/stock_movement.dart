import 'package:loxia/loxia.dart';
import 'package:pos_backend/enums/stock_change_reason.dart';
import 'package:pos_backend/models/product/product.dart';
import 'package:pos_backend/models/stock/stock.dart';
import 'package:pos_backend/models/store/store.dart';

part 'stock_movement.g.dart';

/// Append-only audit log for stock movements.
@EntityMeta(table: 'stock_movements')
class StockMovement extends Entity {
  /// Creates a stock movement row.
  StockMovement({
    required this.id,
    required this.reason,
    required this.quantityBefore,
    required this.quantityChange,
    required this.quantityAfter,
    this.note,
    this.stock,
    this.store,
    this.product,
    this.createdAt,
  });

  /// Unique identifier for this movement.
  @PrimaryKey(uuid: true)
  final String id;

  /// Server-owned reason code for this movement.
  @Column(type: ColumnType.text)
  final StockChangeReason reason;

  /// Quantity before applying this movement.
  @Column()
  final int quantityBefore;

  /// Signed quantity delta.
  @Column()
  final int quantityChange;

  /// Quantity after applying this movement.
  @Column()
  final int quantityAfter;

  /// Optional note attached to this movement.
  @Column()
  final String? note;

  /// Stock row affected.
  @ManyToOne(on: Stock)
  @JoinColumn(name: 'stock_id')
  final Stock? stock;

  /// Store where movement happened.
  @ManyToOne(on: Store)
  @JoinColumn(name: 'store_id')
  final Store? store;

  /// Product whose stock changed.
  @ManyToOne(on: Product)
  @JoinColumn(name: 'product_id')
  final Product? product;

  /// Timestamp when movement was created.
  @CreatedAt()
  DateTime? createdAt;

  /// Entity descriptor used by Loxia for metadata and query operations.
  static EntityDescriptor<StockMovement, StockMovementPartial> get entity =>
      $StockMovementEntityDescriptor;
}
