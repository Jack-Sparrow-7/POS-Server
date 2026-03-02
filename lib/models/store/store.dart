import 'package:loxia/loxia.dart';
import 'package:pos_backend/enums/store_type.dart';
import 'package:pos_backend/models/category/category.dart';
import 'package:pos_backend/models/counter/counter.dart';
import 'package:pos_backend/models/merchant/merchant.dart';
import 'package:pos_backend/models/product/product.dart';
import 'package:pos_backend/models/terminal/terminal.dart';

part 'store.g.dart';

/// Represents a merchant store location or outlet.
@EntityMeta(
  table: 'stores',
  uniqueConstraints: [
    UniqueConstraint(columns: ['name', 'merchant_id']),
  ],
)
class Store extends Entity {
  /// Creates a store record.
  Store({
    required this.id,
    required this.name,
    required this.email,
    required this.type,
    this.whatsappNumber,
    this.isActive = true,
    this.onlineOrderingEnabled = true,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.merchant,
    this.terminals = const [],
    this.categories = const [],
    this.counters = const [],
    this.products = const [],
  });

  /// Unique identifier for the store.
  @PrimaryKey(uuid: true)
  final String id;

  /// Store display name.
  @Column()
  final String name;

  /// Contact email for the store.
  @Column()
  final String email;

  /// Optional WhatsApp contact number.
  @Column()
  final String? whatsappNumber;

  /// Business category of the store.
  @Column(type: ColumnType.text)
  final StoreType type;

  /// Whether this store is active.
  @Column()
  bool isActive;

  /// Whether customer online ordering is enabled for this store.
  @Column()
  bool onlineOrderingEnabled;

  /// Timestamp when the store record was created.
  @CreatedAt()
  DateTime? createdAt;

  /// Timestamp when the store record was last updated.
  @UpdatedAt()
  DateTime? updatedAt;

  /// Timestamp when the store was soft-deleted.
  @DeletedAt()
  DateTime? deletedAt;

  /// Merchant that owns this store.
  @ManyToOne(on: Merchant)
  @JoinColumn(name: 'merchant_id')
  final Merchant? merchant;

  /// Terminals associated with this store
  @OneToMany(on: Terminal, mappedBy: 'store')
  final List<Terminal> terminals;

  /// Categories associated with this store
  @OneToMany(on: Category, mappedBy: 'store')
  final List<Category> categories;

  /// Counters associated with this store
  @OneToMany(on: Counter, mappedBy: 'store')
  final List<Counter> counters;

  /// Products associated with this store
  @OneToMany(on: Product, mappedBy: 'store')
  final List<Product> products;

  /// Entity descriptor used by Loxia for metadata and query operations.
  static EntityDescriptor<Store, StorePartial> get entity =>
      $StoreEntityDescriptor;
}
