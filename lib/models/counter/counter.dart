import 'package:loxia/loxia.dart';
import 'package:pos_backend/models/store/store.dart';

part 'counter.g.dart';

/// Represents a product/service counter under a store.
@EntityMeta(
  table: 'counters',
  uniqueConstraints: [
    UniqueConstraint(columns: ['name', 'store_id']),
  ],
)
class Counter extends Entity {
  /// Creates a counter record.
  Counter({
    required this.id,
    required this.name,
    required this.description,
    this.isActive = true,
    this.store,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  /// Unique identifier for the counter.
  @PrimaryKey(uuid: true)
  final String id;

  /// Counter display name.
  @Column()
  final String name;

  /// Optional counter description.
  @Column()
  final String? description;

  /// Whether this counter is currently active.
  @Column()
  final bool isActive;

  /// Store that owns this counter.
  @ManyToOne(on: Store)
  @JoinColumn(name: 'store_id')
  final Store? store;

  /// Timestamp when the Counter was created.
  @CreatedAt()
  DateTime? createdAt;

  /// Timestamp when the Counter was last updated.
  @UpdatedAt()
  DateTime? updatedAt;

  /// Timestamp when the counter was soft-deleted.
  @DeletedAt()
  DateTime? deletedAt;

  /// Entity descriptor used by Loxia for metadata and query operations.
  static EntityDescriptor<Counter, CounterPartial> get entity =>
      $CounterEntityDescriptor;
}
