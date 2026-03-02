import 'package:loxia/loxia.dart';
import 'package:pos_backend/models/store/store.dart';

part 'terminal.g.dart';

/// Represents a payment terminal assigned to a merchant.
@EntityMeta(table: 'terminals', uniqueConstraints: [
  UniqueConstraint(columns: ['name', 'store_id']),
])
class Terminal extends Entity {
  /// Creates a terminal record.
  Terminal({
    required this.id,
    required this.terminalCode,
    required this.passwordHash,
    required this.name,
    this.isActive = true,
    this.tokenVersion = 0,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.store,
  });

  /// Unique identifier for the terminal.
  @PrimaryKey(uuid: true)
  final String id;

  /// Unique terminal code used for authentication.
  @Column(unique: true)
  final String terminalCode;

  /// Hashed password for terminal access.
  @Column()
  final String passwordHash;

  /// Human-readable terminal name.
  @Column()
  final String name;

  /// Whether this terminal can authenticate and operate.
  @Column()
  bool isActive;

  /// JWT version for forced token invalidation.
  @Column()
  int tokenVersion;

  /// Timestamp when the terminal was created.
  @CreatedAt()
  DateTime? createdAt;

  /// Timestamp when the terminal was last updated.
  @UpdatedAt()
  DateTime? updatedAt;

  /// Timestamp when the terminal was soft-deleted.
  @DeletedAt()
  DateTime? deletedAt;

  /// Store owns this terminal
  @ManyToOne(on: Store)
  @JoinColumn(name: 'store_id')
  final Store? store;

  /// Entity descriptor used by Loxia for metadata and query operations.
  static EntityDescriptor<Terminal, TerminalPartial> get entity =>
      $TerminalEntityDescriptor;
}
