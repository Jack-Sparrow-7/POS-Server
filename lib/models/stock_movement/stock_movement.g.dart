// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_movement.dart';

// **************************************************************************
// LoxiaEntityGenerator
// **************************************************************************

final EntityDescriptor<StockMovement, StockMovementPartial>
$StockMovementEntityDescriptor = () {
  $initStockMovementJsonCodec();
  return EntityDescriptor(
    entityType: StockMovement,
    tableName: 'stock_movements',
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
        name: 'reason',
        propertyName: 'reason',
        type: ColumnType.text,
        nullable: false,
        unique: false,
        isPrimaryKey: false,
        autoIncrement: false,
        uuid: false,
        isDeletedAt: false,
      ),
      ColumnDescriptor(
        name: 'quantity_before',
        propertyName: 'quantityBefore',
        type: ColumnType.integer,
        nullable: false,
        unique: false,
        isPrimaryKey: false,
        autoIncrement: false,
        uuid: false,
        isDeletedAt: false,
      ),
      ColumnDescriptor(
        name: 'quantity_change',
        propertyName: 'quantityChange',
        type: ColumnType.integer,
        nullable: false,
        unique: false,
        isPrimaryKey: false,
        autoIncrement: false,
        uuid: false,
        isDeletedAt: false,
      ),
      ColumnDescriptor(
        name: 'quantity_after',
        propertyName: 'quantityAfter',
        type: ColumnType.integer,
        nullable: false,
        unique: false,
        isPrimaryKey: false,
        autoIncrement: false,
        uuid: false,
        isDeletedAt: false,
      ),
      ColumnDescriptor(
        name: 'note',
        propertyName: 'note',
        type: ColumnType.text,
        nullable: true,
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
    ],
    relations: const [
      RelationDescriptor(
        fieldName: 'stock',
        type: RelationType.manyToOne,
        target: Stock,
        isOwningSide: true,
        fetch: RelationFetchStrategy.lazy,
        cascade: const [],
        cascadePersist: false,
        cascadeMerge: false,
        cascadeRemove: false,
        joinColumn: JoinColumnDescriptor(
          name: 'stock_id',
          referencedColumnName: 'id',
          nullable: true,
          unique: false,
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
      RelationDescriptor(
        fieldName: 'product',
        type: RelationType.manyToOne,
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
          unique: false,
        ),
      ),
    ],
    fromRow: (row) => StockMovement(
      id: (row['id'] as String),
      reason: StockChangeReason.values.byName(row['reason'] as String),
      quantityBefore: (row['quantity_before'] as int),
      quantityChange: (row['quantity_change'] as int),
      quantityAfter: (row['quantity_after'] as int),
      note: (row['note'] as String?),
      createdAt: row['created_at'] == null
          ? null
          : row['created_at'] is String
          ? DateTime.parse(row['created_at'].toString())
          : row['created_at'] as DateTime,
      stock: null,
      store: null,
      product: null,
    ),
    toRow: (e) => {
      'id': e.id,
      'reason': e.reason.name,
      'quantity_before': e.quantityBefore,
      'quantity_change': e.quantityChange,
      'quantity_after': e.quantityAfter,
      'note': e.note,
      'created_at': e.createdAt?.toIso8601String(),
      'stock_id': e.stock?.id,
      'store_id': e.store?.id,
      'product_id': e.product?.id,
    },
    fieldsContext: const StockMovementFieldsContext(),
    repositoryFactory: (EngineAdapter engine) =>
        StockMovementRepository(engine),
    hooks: EntityHooks<StockMovement>(
      prePersist: (e) {
        e.createdAt = DateTime.now();
      },
    ),
    defaultSelect: () => StockMovementSelect(),
  );
}();

class StockMovementFieldsContext extends QueryFieldsContext<StockMovement> {
  const StockMovementFieldsContext([super.runtimeContext, super.alias]);

  @override
  StockMovementFieldsContext bind(
    QueryRuntimeContext runtimeContext,
    String alias,
  ) => StockMovementFieldsContext(runtimeContext, alias);

  QueryField<String> get id => field<String>('id');

  QueryField<StockChangeReason> get reason =>
      field<StockChangeReason>('reason');

  QueryField<int> get quantityBefore => field<int>('quantity_before');

  QueryField<int> get quantityChange => field<int>('quantity_change');

  QueryField<int> get quantityAfter => field<int>('quantity_after');

  QueryField<String?> get note => field<String?>('note');

  QueryField<DateTime?> get createdAt => field<DateTime?>('created_at');

  QueryField<String?> get stockId => field<String?>('stock_id');

  QueryField<String?> get storeId => field<String?>('store_id');

  QueryField<String?> get productId => field<String?>('product_id');

  StockFieldsContext get stock {
    final alias = ensureRelationJoin(
      relationName: 'stock',
      targetTableName: $StockEntityDescriptor.qualifiedTableName,
      localColumn: 'stock_id',
      foreignColumn: 'id',
      joinType: JoinType.left,
    );
    return StockFieldsContext(runtimeOrThrow, alias);
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
}

class StockMovementQuery extends QueryBuilder<StockMovement> {
  const StockMovementQuery(this._builder);

  final WhereExpression Function(StockMovementFieldsContext) _builder;

  @override
  WhereExpression build(QueryFieldsContext<StockMovement> context) {
    if (context is! StockMovementFieldsContext) {
      throw ArgumentError(
        'Expected StockMovementFieldsContext for StockMovementQuery',
      );
    }
    return _builder(context);
  }
}

class StockMovementSelect
    extends SelectOptions<StockMovement, StockMovementPartial> {
  const StockMovementSelect({
    this.id = true,
    this.reason = true,
    this.quantityBefore = true,
    this.quantityChange = true,
    this.quantityAfter = true,
    this.note = true,
    this.createdAt = true,
    this.stockId = true,
    this.storeId = true,
    this.productId = true,
    this.relations,
  });

  final bool id;

  final bool reason;

  final bool quantityBefore;

  final bool quantityChange;

  final bool quantityAfter;

  final bool note;

  final bool createdAt;

  final bool stockId;

  final bool storeId;

  final bool productId;

  final StockMovementRelations? relations;

  @override
  bool get hasSelections =>
      id ||
      reason ||
      quantityBefore ||
      quantityChange ||
      quantityAfter ||
      note ||
      createdAt ||
      stockId ||
      storeId ||
      productId ||
      (relations?.hasSelections ?? false);

  @override
  SelectOptions<StockMovement, StockMovementPartial> withRelations(
    RelationsOptions<StockMovement, StockMovementPartial>? relations,
  ) {
    return StockMovementSelect(
      id: id,
      reason: reason,
      quantityBefore: quantityBefore,
      quantityChange: quantityChange,
      quantityAfter: quantityAfter,
      note: note,
      createdAt: createdAt,
      stockId: stockId,
      storeId: storeId,
      productId: productId,
      relations: relations as StockMovementRelations?,
    );
  }

  @override
  void collect(
    QueryFieldsContext<StockMovement> context,
    List<SelectField> out, {
    String? path,
  }) {
    if (context is! StockMovementFieldsContext) {
      throw ArgumentError(
        'Expected StockMovementFieldsContext for StockMovementSelect',
      );
    }
    final StockMovementFieldsContext scoped = context;
    String? aliasFor(String column) {
      final current = path;
      if (current == null || current.isEmpty) return null;
      return '${current}_$column';
    }

    final tableAlias = scoped.currentAlias;
    if (id) {
      out.add(SelectField('id', tableAlias: tableAlias, alias: aliasFor('id')));
    }
    if (reason) {
      out.add(
        SelectField(
          'reason',
          tableAlias: tableAlias,
          alias: aliasFor('reason'),
        ),
      );
    }
    if (quantityBefore) {
      out.add(
        SelectField(
          'quantity_before',
          tableAlias: tableAlias,
          alias: aliasFor('quantity_before'),
        ),
      );
    }
    if (quantityChange) {
      out.add(
        SelectField(
          'quantity_change',
          tableAlias: tableAlias,
          alias: aliasFor('quantity_change'),
        ),
      );
    }
    if (quantityAfter) {
      out.add(
        SelectField(
          'quantity_after',
          tableAlias: tableAlias,
          alias: aliasFor('quantity_after'),
        ),
      );
    }
    if (note) {
      out.add(
        SelectField('note', tableAlias: tableAlias, alias: aliasFor('note')),
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
    if (stockId) {
      out.add(
        SelectField(
          'stock_id',
          tableAlias: tableAlias,
          alias: aliasFor('stock_id'),
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
    if (productId) {
      out.add(
        SelectField(
          'product_id',
          tableAlias: tableAlias,
          alias: aliasFor('product_id'),
        ),
      );
    }
    final rels = relations;
    if (rels != null && rels.hasSelections) {
      rels.collect(scoped, out, path: path);
    }
  }

  @override
  StockMovementPartial hydrate(Map<String, dynamic> row, {String? path}) {
    StockPartial? stockPartial;
    final stockSelect = relations?.stock;
    if (stockSelect != null && stockSelect.hasSelections) {
      stockPartial = stockSelect.hydrate(row, path: extendPath(path, 'stock'));
    }
    StorePartial? storePartial;
    final storeSelect = relations?.store;
    if (storeSelect != null && storeSelect.hasSelections) {
      storePartial = storeSelect.hydrate(row, path: extendPath(path, 'store'));
    }
    ProductPartial? productPartial;
    final productSelect = relations?.product;
    if (productSelect != null && productSelect.hasSelections) {
      productPartial = productSelect.hydrate(
        row,
        path: extendPath(path, 'product'),
      );
    }
    return StockMovementPartial(
      id: id ? readValue(row, 'id', path: path) as String : null,
      reason: reason
          ? StockChangeReason.values.byName(
              readValue(row, 'reason', path: path) as String,
            )
          : null,
      quantityBefore: quantityBefore
          ? readValue(row, 'quantity_before', path: path) as int
          : null,
      quantityChange: quantityChange
          ? readValue(row, 'quantity_change', path: path) as int
          : null,
      quantityAfter: quantityAfter
          ? readValue(row, 'quantity_after', path: path) as int
          : null,
      note: note ? readValue(row, 'note', path: path) as String? : null,
      createdAt: createdAt
          ? readValue(row, 'created_at', path: path) == null
                ? null
                : (readValue(row, 'created_at', path: path) is String
                      ? DateTime.parse(
                          readValue(row, 'created_at', path: path) as String,
                        )
                      : readValue(row, 'created_at', path: path) as DateTime)
          : null,
      stockId: stockId
          ? readValue(row, 'stock_id', path: path) as String?
          : null,
      stock: stockPartial,
      storeId: storeId
          ? readValue(row, 'store_id', path: path) as String?
          : null,
      store: storePartial,
      productId: productId
          ? readValue(row, 'product_id', path: path) as String?
          : null,
      product: productPartial,
    );
  }

  @override
  bool get hasCollectionRelations => false;

  @override
  String? get primaryKeyColumn => 'id';
}

class StockMovementRelations
    extends RelationsOptions<StockMovement, StockMovementPartial> {
  const StockMovementRelations({this.stock, this.store, this.product});

  final StockSelect? stock;

  final StoreSelect? store;

  final ProductSelect? product;

  @override
  bool get hasSelections =>
      (stock?.hasSelections ?? false) ||
      (store?.hasSelections ?? false) ||
      (product?.hasSelections ?? false);

  @override
  void collect(
    QueryFieldsContext<StockMovement> context,
    List<SelectField> out, {
    String? path,
  }) {
    if (context is! StockMovementFieldsContext) {
      throw ArgumentError(
        'Expected StockMovementFieldsContext for StockMovementRelations',
      );
    }
    final StockMovementFieldsContext scoped = context;

    final stockSelect = stock;
    if (stockSelect != null && stockSelect.hasSelections) {
      final relationPath = path == null || path.isEmpty
          ? 'stock'
          : '${path}_stock';
      final relationContext = scoped.stock;
      stockSelect.collect(relationContext, out, path: relationPath);
    }
    final storeSelect = store;
    if (storeSelect != null && storeSelect.hasSelections) {
      final relationPath = path == null || path.isEmpty
          ? 'store'
          : '${path}_store';
      final relationContext = scoped.store;
      storeSelect.collect(relationContext, out, path: relationPath);
    }
    final productSelect = product;
    if (productSelect != null && productSelect.hasSelections) {
      final relationPath = path == null || path.isEmpty
          ? 'product'
          : '${path}_product';
      final relationContext = scoped.product;
      productSelect.collect(relationContext, out, path: relationPath);
    }
  }
}

class StockMovementPartial extends PartialEntity<StockMovement> {
  const StockMovementPartial({
    this.id,
    this.reason,
    this.quantityBefore,
    this.quantityChange,
    this.quantityAfter,
    this.note,
    this.createdAt,
    this.stockId,
    this.stock,
    this.storeId,
    this.store,
    this.productId,
    this.product,
  });

  final String? id;

  final StockChangeReason? reason;

  final int? quantityBefore;

  final int? quantityChange;

  final int? quantityAfter;

  final String? note;

  final DateTime? createdAt;

  final String? stockId;

  final String? storeId;

  final String? productId;

  final StockPartial? stock;

  final StorePartial? store;

  final ProductPartial? product;

  @override
  Object? get primaryKeyValue {
    return id;
  }

  @override
  StockMovementInsertDto toInsertDto() {
    final missing = <String>[];
    if (reason == null) missing.add('reason');
    if (quantityBefore == null) missing.add('quantityBefore');
    if (quantityChange == null) missing.add('quantityChange');
    if (quantityAfter == null) missing.add('quantityAfter');
    if (missing.isNotEmpty) {
      throw StateError(
        'Cannot convert StockMovementPartial to StockMovementInsertDto: missing required fields: ${missing.join(', ')}',
      );
    }
    return StockMovementInsertDto(
      reason: reason!,
      quantityBefore: quantityBefore!,
      quantityChange: quantityChange!,
      quantityAfter: quantityAfter!,
      note: note,
      createdAt: createdAt,
      stockId: stockId,
      storeId: storeId,
      productId: productId,
    );
  }

  @override
  StockMovementUpdateDto toUpdateDto() {
    return StockMovementUpdateDto(
      reason: reason,
      quantityBefore: quantityBefore,
      quantityChange: quantityChange,
      quantityAfter: quantityAfter,
      note: note,
      createdAt: createdAt,
      stockId: stockId,
      storeId: storeId,
      productId: productId,
    );
  }

  @override
  StockMovement toEntity() {
    final missing = <String>[];
    if (id == null) missing.add('id');
    if (reason == null) missing.add('reason');
    if (quantityBefore == null) missing.add('quantityBefore');
    if (quantityChange == null) missing.add('quantityChange');
    if (quantityAfter == null) missing.add('quantityAfter');
    if (missing.isNotEmpty) {
      throw StateError(
        'Cannot convert StockMovementPartial to StockMovement: missing required fields: ${missing.join(', ')}',
      );
    }
    return StockMovement(
      id: id!,
      reason: reason!,
      quantityBefore: quantityBefore!,
      quantityChange: quantityChange!,
      quantityAfter: quantityAfter!,
      note: note,
      createdAt: createdAt,
      stock: stock?.toEntity(),
      store: store?.toEntity(),
      product: product?.toEntity(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (reason != null) 'reason': reason?.name,
      if (quantityBefore != null) 'quantityBefore': quantityBefore,
      if (quantityChange != null) 'quantityChange': quantityChange,
      if (quantityAfter != null) 'quantityAfter': quantityAfter,
      if (note != null) 'note': note,
      if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
      if (stock != null) 'stock': stock?.toJson(),
      if (store != null) 'store': store?.toJson(),
      if (product != null) 'product': product?.toJson(),
      if (stockId != null) 'stockId': stockId,
      if (storeId != null) 'storeId': storeId,
      if (productId != null) 'productId': productId,
    };
  }
}

class StockMovementInsertDto implements InsertDto<StockMovement> {
  const StockMovementInsertDto({
    required this.reason,
    required this.quantityBefore,
    required this.quantityChange,
    required this.quantityAfter,
    this.note,
    this.createdAt,
    this.stockId,
    this.storeId,
    this.productId,
  });

  final StockChangeReason reason;

  final int quantityBefore;

  final int quantityChange;

  final int quantityAfter;

  final String? note;

  final DateTime? createdAt;

  final String? stockId;

  final String? storeId;

  final String? productId;

  @override
  Map<String, dynamic> toMap() {
    return {
      'reason': reason.name,
      'quantity_before': quantityBefore,
      'quantity_change': quantityChange,
      'quantity_after': quantityAfter,
      'note': note,
      'created_at': DateTime.now().toIso8601String(),
      if (stockId != null) 'stock_id': stockId,
      if (storeId != null) 'store_id': storeId,
      if (productId != null) 'product_id': productId,
    };
  }

  Map<String, dynamic> get cascades {
    return const {};
  }

  StockMovementInsertDto copyWith({
    StockChangeReason? reason,
    int? quantityBefore,
    int? quantityChange,
    int? quantityAfter,
    String? note,
    DateTime? createdAt,
    String? stockId,
    String? storeId,
    String? productId,
  }) {
    return StockMovementInsertDto(
      reason: reason ?? this.reason,
      quantityBefore: quantityBefore ?? this.quantityBefore,
      quantityChange: quantityChange ?? this.quantityChange,
      quantityAfter: quantityAfter ?? this.quantityAfter,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      stockId: stockId ?? this.stockId,
      storeId: storeId ?? this.storeId,
      productId: productId ?? this.productId,
    );
  }
}

class StockMovementUpdateDto implements UpdateDto<StockMovement> {
  const StockMovementUpdateDto({
    this.reason,
    this.quantityBefore,
    this.quantityChange,
    this.quantityAfter,
    this.note,
    this.createdAt,
    this.stockId,
    this.storeId,
    this.productId,
  });

  final StockChangeReason? reason;

  final int? quantityBefore;

  final int? quantityChange;

  final int? quantityAfter;

  final String? note;

  final DateTime? createdAt;

  final String? stockId;

  final String? storeId;

  final String? productId;

  @override
  Map<String, dynamic> toMap() {
    return {
      if (reason != null) 'reason': reason?.name,
      if (quantityBefore != null) 'quantity_before': quantityBefore,
      if (quantityChange != null) 'quantity_change': quantityChange,
      if (quantityAfter != null) 'quantity_after': quantityAfter,
      if (note != null) 'note': note,
      if (createdAt != null)
        'created_at': createdAt is DateTime
            ? (createdAt as DateTime).toIso8601String()
            : createdAt?.toString(),
      if (stockId != null) 'stock_id': stockId,
      if (storeId != null) 'store_id': storeId,
      if (productId != null) 'product_id': productId,
    };
  }

  Map<String, dynamic> get cascades {
    return const {};
  }
}

class StockMovementRepository
    extends EntityRepository<StockMovement, StockMovementPartial> {
  StockMovementRepository(EngineAdapter engine)
    : super(
        $StockMovementEntityDescriptor,
        engine,
        $StockMovementEntityDescriptor.fieldsContext,
      );
}

extension StockMovementJson on StockMovement {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reason': reason.name,
      'quantityBefore': quantityBefore,
      'quantityChange': quantityChange,
      'quantityAfter': quantityAfter,
      if (note != null) 'note': note,
      if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
      if (stock != null) 'stock': stock?.toJson(),
      if (store != null) 'store': store?.toJson(),
      if (product != null) 'product': product?.toJson(),
    };
  }
}

extension StockMovementCodec on StockMovement {
  Object? toEncodable() {
    return toJson();
  }

  String toJsonString() {
    return encodeJsonColumn(toJson()) as String;
  }
}

extension StockMovementPartialCodec on StockMovementPartial {
  Object? toEncodable() {
    return toJson();
  }

  String toJsonString() {
    return encodeJsonColumn(toJson()) as String;
  }
}

var $isStockMovementJsonCodecInitialized = false;
void $initStockMovementJsonCodec() {
  if ($isStockMovementJsonCodecInitialized) return;
  EntityJsonRegistry.register<StockMovement>(
    (value) => StockMovementJson(value).toJson(),
  );
  $isStockMovementJsonCodecInitialized = true;
}

extension StockMovementRepositoryExtensions
    on EntityRepository<StockMovement, PartialEntity<StockMovement>> {}
