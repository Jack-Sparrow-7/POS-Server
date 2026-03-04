import 'package:loxia/loxia.dart';

part 'customer.g.dart';

/// Represents a public customer account.
@EntityMeta(table: 'customers')
class Customer extends Entity {
  /// Creates a customer record.
  Customer({
    required this.id,
    required this.name,
    required this.mobileNumber,
    required this.email,
    required this.passwordHash,
    this.isActive = true,
    this.tokenVersion = 0,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
  });

  /// Unique identifier for the customer.
  @PrimaryKey(uuid: true)
  final String id;

  /// Customer full name.
  @Column()
  final String name;

  /// Customer mobile number.
  @Column(unique: true)
  final String mobileNumber;

  /// Customer email address.
  @Column(unique: true)
  final String email;

  /// Hashed password used for authentication.
  @Column()
  final String passwordHash;

  /// Whether this customer account is active.
  @Column()
  bool isActive;

  /// JWT version for forced token invalidation.
  @Column()
  int tokenVersion;

  /// Timestamp when the customer was created.
  @CreatedAt()
  DateTime? createdAt;

  /// Timestamp when the customer was last updated.
  @UpdatedAt()
  DateTime? updatedAt;

  /// Timestamp when the customer was soft-deleted.
  @DeletedAt()
  DateTime? deletedAt;

  /// Entity descriptor used by Loxia for metadata and query operations.
  static EntityDescriptor<Customer, CustomerPartial> get entity =>
      $CustomerEntityDescriptor;
}
