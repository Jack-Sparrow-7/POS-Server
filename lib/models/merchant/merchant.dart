import 'package:loxia/loxia.dart';
import 'package:pos_backend/models/store/store.dart';
part 'merchant.g.dart';

/// Represents a merchant account in the system.
@EntityMeta(table: 'merchants')
class Merchant extends Entity {
  /// Creates a merchant record.
  Merchant({
    required this.id,
    required this.name,
    required this.businessName,
    required this.mobileNumber,
    required this.email,
    required this.passwordHash,
    this.stores = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// Unique identifier for the merchant.
  @PrimaryKey(uuid: true)
  final String id;

  /// Merchant owner's full name.
  @Column()
  final String name;

  /// Registered business name.
  @Column()
  final String businessName;

  /// Merchant mobile number.
  @Column(unique: true)
  final String mobileNumber;

  /// Merchant email address.
  @Column(unique: true)
  final String email;

  /// Hashed password used for authentication.
  @Column()
  final String passwordHash;

  /// Stores associated with this merchant.
  @OneToMany(on: Store, mappedBy: 'merchant')
  final List<Store> stores;

  /// Timestamp when the merchant was created.
  @CreatedAt()
  DateTime? createdAt;

  /// Timestamp when the merchant was last updated.
  @UpdatedAt()
  DateTime? updatedAt;

  /// Entity descriptor used by Loxia for metadata and query operations.
  static EntityDescriptor<Merchant, MerchantPartial> get entity =>
      $MerchantEntityDescriptor;
}
