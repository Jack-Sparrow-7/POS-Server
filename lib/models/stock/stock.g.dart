// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock.dart';

// **************************************************************************
// LoxiaEntityGenerator
// **************************************************************************

final EntityDescriptor<Stock, StockPartial> $StockEntityDescriptor = () {
  $initStockJsonCodec();
  return EntityDescriptor(
    entityType: Stock,
    tableName: 'stock',
    columns: [
      ColumnDescriptor(
        name: 'id',
        propertyName: 'id',
        type: ColumnType.uuid,
        nullable: false,
        unique: false,
        isPrimaryKey: true,
        autoIncrement: false,
        uuid: true,
        isDeletedAt: false,
      ),
      ColumnDescriptor(
        name: 'quantity',
        propertyName: 'quantity',
        type: ColumnType.integer,
        nullable: false,
        unique: false,
        isPrimaryKey: false,
        autoIncrement: false,
        uuid: false,
        isDeletedAt: false,
      ),
      ColumnDescriptor(
        name: 'low_stock_threshold',
        propertyName: 'lowStockThreshold',
        type: ColumnType.integer,
        nullable: false,
        unique: false,
        isPrimaryKey: false,
        autoIncrement: false,
        uuid: false,
        isDeletedAt: false,
      ),
      ColumnDescriptor(
        name: 'created_at',
        propertyName: 'createdAt',
        type: ColumnType.dateTime,
        nullable: true,
        unique: false,
        isPrimaryKey: false,
        autoIncrement: false,
        uuid: false,
        isDeletedAt: false,
      ),
      ColumnDescriptor(
        name: 'updated_at',
        propertyName: 'updatedAt',
        type: ColumnType.dateTime,
        nullable: true,
        unique: false,
        isPrimaryKey: false,
        autoIncrement: false,
        uuid: false,
        isDeletedAt: false,
      ),
    ],
    relations: const [
      RelationDescriptor(
        fieldName: 'product',
        type: RelationType.oneToOne,
        target: Product,
        isOwningSide: true,
        fetch: RelationFetchStrategy.lazy,
        cascade: const [],
        cascadePersist: false,
        cascadeMerge: false,
        cascadeRemove: false,
        joinColumn: JoinColumnDescriptor(
          name: 'product_id',
          referencedColumnName: 'id',
          nullable: true,
          unique: true,
        ),
      ),
      RelationDescriptor(
        fieldName: 'store',
        type: RelationType.manyToOne,
        target: Store,
        isOwningSide: true,
        fetch: RelationFetchStrategy.lazy,
        cascade: const [],
        cascadePersist: false,
        cascadeMerge: false,
        cascadeRemove: false,
        joinColumn: JoinColumnDescriptor(
          name: 'store_id',
          referencedColumnName: 'id',
          nullable: true,
          unique: false,
        ),
      ),
    ],
    uniqueConstraints: const [
      UniqueConstraintDescriptor(columns: ['product_id', 'store_id']),
    ],
    fromRow: (row) => Stock(
      id: (row['id'] as String),
      quantity: (row['quantity'] as int),
      lowStockThreshold: (row['low_stock_threshold'] as int),
      createdAt: row['created_at'] == null
          ? null
          : row['created_at'] is String
          ? DateTime.parse(row['created_at'].toString())
          : row['created_at'] as DateTime,
      updatedAt: row['updated_at'] == null
          ? null
          : row['updated_at'] is String
          ? DateTime.parse(row['updated_at'].toString())
          : row['updated_at'] as DateTime,
      product: null,
      store: null,
    ),
    toRow: (e) => {
      'id': e.id,
      'quantity': e.quantity,
      'low_stock_threshold': e.lowStockThreshold,
      'created_at': e.createdAt?.toIso8601String(),
      'updated_at': e.updatedAt?.toIso8601String(),
      'product_id': e.product?.id,
      'store_id': e.store?.id,
    },
    fieldsContext: const StockFieldsContext(),
    repositoryFactory: (EngineAdapter engine) => StockRepository(engine),
    hooks: EntityHooks<Stock>(
      prePersist: (e) {
        e.createdAt = DateTime.now();
        e.updatedAt = DateTime.now();
      },
      preUpdate: (e) {
        e.updatedAt = DateTime.now();
      },
    ),
    defaultSelect: () => StockSelect(),
  );
}();

class StockFieldsContext extends QueryFieldsContext<Stock> {
  const StockFieldsContext([super.runtimeContext, super.alias]);

  @override
  StockFieldsContext bind(QueryRuntimeContext runtimeContext, String alias) =>
      StockFieldsContext(runtimeContext, alias);

  QueryField<String> get id => field<String>('id');

  QueryField<int> get quantity => field<int>('quantity');

  QueryField<int> get lowStockThreshold => field<int>('low_stock_threshold');

  QueryField<DateTime?> get createdAt => field<DateTime?>('created_at');

  QueryField<DateTime?> get updatedAt => field<DateTime?>('updated_at');

  QueryField<String?> get productId => field<String?>('product_id');

  QueryField<String?> get storeId => field<String?>('store_id');

  ProductFieldsContext get product {
    final alias = ensureRelationJoin(
      relationName: 'product',
      targetTableName: $ProductEntityDescriptor.qualifiedTableName,
      localColumn: 'product_id',
      foreignColumn: 'id',
      joinType: JoinType.left,
    );
    return ProductFieldsContext(runtimeOrThrow, alias);
  }

  StoreFieldsContext get store {
    final alias = ensureRelationJoin(
      relationName: 'store',
      targetTableName: $StoreEntityDescriptor.qualifiedTableName,
      localColumn: 'store_id',
      foreignColumn: 'id',
      joinType: JoinType.left,
    );
    return StoreFieldsContext(runtimeOrThrow, alias);
  }
}

class StockQuery extends QueryBuilder<Stock> {
  const StockQuery(this._builder);

  final WhereExpression Function(StockFieldsContext) _builder;

  @override
  WhereExpression build(QueryFieldsContext<Stock> context) {
    if (context is! StockFieldsContext) {
      throw ArgumentError('Expected StockFieldsContext for StockQuery');
    }
    return _builder(context);
  }
}

class StockSelect extends SelectOptions<Stock, StockPartial> {
  const StockSelect({
    this.id = true,
    this.quantity = true,
    this.lowStockThreshold = true,
    this.createdAt = true,
    this.updatedAt = true,
    this.productId = true,
    this.storeId = true,
    this.relations,
  });

  final bool id;

  final bool quantity;

  final bool lowStockThreshold;

  final bool createdAt;

  final bool updatedAt;

  final bool productId;

  final bool storeId;

  final StockRelations? relations;

  @override
  bool get hasSelections =>
      id ||
      quantity ||
      lowStockThreshold ||
      createdAt ||
      updatedAt ||
      productId ||
      storeId ||
      (relations?.hasSelections ?? false);

  @override
  SelectOptions<Stock, StockPartial> withRelations(
    RelationsOptions<Stock, StockPartial>? relations,
  ) {
    return StockSelect(
      id: id,
      quantity: quantity,
      lowStockThreshold: lowStockThreshold,
      createdAt: createdAt,
      updatedAt: updatedAt,
      productId: productId,
      storeId: storeId,
      relations: relations as StockRelations?,
    );
  }

  @override
  void collect(
    QueryFieldsContext<Stock> context,
    List<SelectField> out, {
    String? path,
  }) {
    if (context is! StockFieldsContext) {
      throw ArgumentError('Expected StockFieldsContext for StockSelect');
    }
    final StockFieldsContext scoped = context;
    String? aliasFor(String column) {
      final current = path;
      if (current == null || current.isEmpty) return null;
      return '${current}_$column';
    }

    final tableAlias = scoped.currentAlias;
    if (id) {
      out.add(SelectField('id', tableAlias: tableAlias, alias: aliasFor('id')));
    }
    if (quantity) {
      out.add(
        SelectField(
          'quantity',
          tableAlias: tableAlias,
          alias: aliasFor('quantity'),
        ),
      );
    }
    if (lowStockThreshold) {
      out.add(
        SelectField(
          'low_stock_threshold',
          tableAlias: tableAlias,
          alias: aliasFor('low_stock_threshold'),
        ),
      );
    }
    if (createdAt) {
      out.add(
        SelectField(
          'created_at',
          tableAlias: tableAlias,
          alias: aliasFor('created_at'),
        ),
      );
    }
    if (updatedAt) {
      out.add(
        SelectField(
          'updated_at',
          tableAlias: tableAlias,
          alias: aliasFor('updated_at'),
        ),
      );
    }
    if (productId) {
      out.add(
        SelectField(
          'product_id',
          tableAlias: tableAlias,
          alias: aliasFor('product_id'),
        ),
      );
    }
    if (storeId) {
      out.add(
        SelectField(
          'store_id',
          tableAlias: tableAlias,
          alias: aliasFor('store_id'),
        ),
      );
    }
    final rels = relations;
    if (rels != null && rels.hasSelections) {
      rels.collect(scoped, out, path: path);
    }
  }

  @override
  StockPartial hydrate(Map<String, dynamic> row, {String? path}) {
    ProductPartial? productPartial;
    final productSelect = relations?.product;
    if (productSelect != null && productSelect.hasSelections) {
      productPartial = productSelect.hydrate(
        row,
        path: extendPath(path, 'product'),
      );
    }
    StorePartial? storePartial;
    final storeSelect = relations?.store;
    if (storeSelect != null && storeSelect.hasSelections) {
      storePartial = storeSelect.hydrate(row, path: extendPath(path, 'store'));
    }
    return StockPartial(
      id: id ? readValue(row, 'id', path: path) as String : null,
      quantity: quantity ? readValue(row, 'quantity', path: path) as int : null,
      lowStockThreshold: lowStockThreshold
          ? readValue(row, 'low_stock_threshold', path: path) as int
          : null,
      createdAt: createdAt
          ? readValue(row, 'created_at', path: path) == null
                ? null
                : (readValue(row, 'created_at', path: path) is String
                      ? DateTime.parse(
                          readValue(row, 'created_at', path: path) as String,
                        )
                      : readValue(row, 'created_at', path: path) as DateTime)
          : null,
      updatedAt: updatedAt
          ? readValue(row, 'updated_at', path: path) == null
                ? null
                : (readValue(row, 'updated_at', path: path) is String
                      ? DateTime.parse(
                          readValue(row, 'updated_at', path: path) as String,
                        )
                      : readValue(row, 'updated_at', path: path) as DateTime)
          : null,
      productId: productId
          ? readValue(row, 'product_id', path: path) as String?
          : null,
      product: productPartial,
      storeId: storeId
          ? readValue(row, 'store_id', path: path) as String?
          : null,
      store: storePartial,
    );
  }

  @override
  bool get hasCollectionRelations => false;

  @override
  String? get primaryKeyColumn => 'id';
}

class StockRelations extends RelationsOptions<Stock, StockPartial> {
  const StockRelations({this.product, this.store});

  final ProductSelect? product;

  final StoreSelect? store;

  @override
  bool get hasSelections =>
      (product?.hasSelections ?? false) || (store?.hasSelections ?? false);

  @override
  void collect(
    QueryFieldsContext<Stock> context,
    List<SelectField> out, {
    String? path,
  }) {
    if (context is! StockFieldsContext) {
      throw ArgumentError('Expected StockFieldsContext for StockRelations');
    }
    final StockFieldsContext scoped = context;

    final productSelect = product;
    if (productSelect != null && productSelect.hasSelections) {
      final relationPath = path == null || path.isEmpty
          ? 'product'
          : '${path}_product';
      final relationContext = scoped.product;
      productSelect.collect(relationContext, out, path: relationPath);
    }
    final storeSelect = store;
    if (storeSelect != null && storeSelect.hasSelections) {
      final relationPath = path == null || path.isEmpty
          ? 'store'
          : '${path}_store';
      final relationContext = scoped.store;
      storeSelect.collect(relationContext, out, path: relationPath);
    }
  }
}

class StockPartial extends PartialEntity<Stock> {
  const StockPartial({
    this.id,
    this.quantity,
    this.lowStockThreshold,
    this.createdAt,
    this.updatedAt,
    this.productId,
    this.product,
    this.storeId,
    this.store,
  });

  final String? id;

  final int? quantity;

  final int? lowStockThreshold;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? productId;

  final String? storeId;

  final ProductPartial? product;

  final StorePartial? store;

  @override
  Object? get primaryKeyValue {
    return id;
  }

  @override
  StockInsertDto toInsertDto() {
    final missing = <String>[];
    if (quantity == null) missing.add('quantity');
    if (lowStockThreshold == null) missing.add('lowStockThreshold');
    if (missing.isNotEmpty) {
      throw StateError(
        'Cannot convert StockPartial to StockInsertDto: missing required fields: ${missing.join(', ')}',
      );
    }
    return StockInsertDto(
      quantity: quantity!,
      lowStockThreshold: lowStockThreshold!,
      createdAt: createdAt,
      updatedAt: updatedAt,
      productId: productId,
      storeId: storeId,
    );
  }

  @override
  StockUpdateDto toUpdateDto() {
    return StockUpdateDto(
      quantity: quantity,
      lowStockThreshold: lowStockThreshold,
      createdAt: createdAt,
      updatedAt: updatedAt,
      productId: productId,
      storeId: storeId,
    );
  }

  @override
  Stock toEntity() {
    final missing = <String>[];
    if (id == null) missing.add('id');
    if (quantity == null) missing.add('quantity');
    if (lowStockThreshold == null) missing.add('lowStockThreshold');
    if (missing.isNotEmpty) {
      throw StateError(
        'Cannot convert StockPartial to Stock: missing required fields: ${missing.join(', ')}',
      );
    }
    return Stock(
      id: id!,
      quantity: quantity!,
      lowStockThreshold: lowStockThreshold!,
      createdAt: createdAt,
      updatedAt: updatedAt,
      product: product?.toEntity(),
      store: store?.toEntity(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (quantity != null) 'quantity': quantity,
      if (lowStockThreshold != null) 'lowStockThreshold': lowStockThreshold,
      if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
      if (product != null) 'product': product?.toJson(),
      if (store != null) 'store': store?.toJson(),
      if (productId != null) 'productId': productId,
      if (storeId != null) 'storeId': storeId,
    };
  }
}

class StockInsertDto implements InsertDto<Stock> {
  const StockInsertDto({
    required this.quantity,
    required this.lowStockThreshold,
    this.createdAt,
    this.updatedAt,
    this.productId,
    this.storeId,
  });

  final int quantity;

  final int lowStockThreshold;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? productId;

  final String? storeId;

  @override
  Map<String, dynamic> toMap() {
    return {
      'quantity': quantity,
      'low_stock_threshold': lowStockThreshold,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      if (productId != null) 'product_id': productId,
      if (storeId != null) 'store_id': storeId,
    };
  }

  Map<String, dynamic> get cascades {
    return const {};
  }

  StockInsertDto copyWith({
    int? quantity,
    int? lowStockThreshold,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? productId,
    String? storeId,
  }) {
    return StockInsertDto(
      quantity: quantity ?? this.quantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      productId: productId ?? this.productId,
      storeId: storeId ?? this.storeId,
    );
  }
}

class StockUpdateDto implements UpdateDto<Stock> {
  const StockUpdateDto({
    this.quantity,
    this.lowStockThreshold,
    this.createdAt,
    this.updatedAt,
    this.productId,
    this.storeId,
  });

  final int? quantity;

  final int? lowStockThreshold;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? productId;

  final String? storeId;

  @override
  Map<String, dynamic> toMap() {
    return {
      if (quantity != null) 'quantity': quantity,
      if (lowStockThreshold != null) 'low_stock_threshold': lowStockThreshold,
      if (createdAt != null)
        'created_at': createdAt is DateTime
            ? (createdAt as DateTime).toIso8601String()
            : createdAt?.toString(),
      'updated_at': DateTime.now().toIso8601String(),
      if (productId != null) 'product_id': productId,
      if (storeId != null) 'store_id': storeId,
    };
  }

  Map<String, dynamic> get cascades {
    return const {};
  }
}

class StockRepository extends EntityRepository<Stock, StockPartial> {
  StockRepository(EngineAdapter engine)
    : super(
        $StockEntityDescriptor,
        engine,
        $StockEntityDescriptor.fieldsContext,
      );
}

extension StockJson on Stock {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'lowStockThreshold': lowStockThreshold,
      if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
      if (product != null) 'product': product?.toJson(),
      if (store != null) 'store': store?.toJson(),
    };
  }
}

extension StockCodec on Stock {
  Object? toEncodable() {
    return toJson();
  }

  String toJsonString() {
    return encodeJsonColumn(toJson()) as String;
  }
}

extension StockPartialCodec on StockPartial {
  Object? toEncodable() {
    return toJson();
  }

  String toJsonString() {
    return encodeJsonColumn(toJson()) as String;
  }
}

var $isStockJsonCodecInitialized = false;
void $initStockJsonCodec() {
  if ($isStockJsonCodecInitialized) return;
  EntityJsonRegistry.register<Stock>((value) => StockJson(value).toJson());
  $isStockJsonCodecInitialized = true;
}

extension StockRepositoryExtensions
    on EntityRepository<Stock, PartialEntity<Stock>> {}
