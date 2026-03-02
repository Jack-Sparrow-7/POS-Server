// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store.dart';

// **************************************************************************
// LoxiaEntityGenerator
// **************************************************************************

final EntityDescriptor<Store, StorePartial> $StoreEntityDescriptor = () {
  $initStoreJsonCodec();
  return EntityDescriptor(
    entityType: Store,
    tableName: 'stores',
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
        name: 'name',
        propertyName: 'name',
        type: ColumnType.text,
        nullable: false,
        unique: false,
        isPrimaryKey: false,
        autoIncrement: false,
        uuid: false,
        isDeletedAt: false,
      ),
      ColumnDescriptor(
        name: 'email',
        propertyName: 'email',
        type: ColumnType.text,
        nullable: false,
        unique: false,
        isPrimaryKey: false,
        autoIncrement: false,
        uuid: false,
        isDeletedAt: false,
      ),
      ColumnDescriptor(
        name: 'whatsapp_number',
        propertyName: 'whatsappNumber',
        type: ColumnType.text,
        nullable: true,
        unique: false,
        isPrimaryKey: false,
        autoIncrement: false,
        uuid: false,
        isDeletedAt: false,
      ),
      ColumnDescriptor(
        name: 'type',
        propertyName: 'type',
        type: ColumnType.text,
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
        fieldName: 'merchant',
        type: RelationType.manyToOne,
        target: Merchant,
        isOwningSide: true,
        fetch: RelationFetchStrategy.lazy,
        cascade: const [],
        cascadePersist: false,
        cascadeMerge: false,
        cascadeRemove: false,
        joinColumn: JoinColumnDescriptor(
          name: 'merchant_id',
          referencedColumnName: 'id',
          nullable: true,
          unique: false,
        ),
      ),
      RelationDescriptor(
        fieldName: 'terminals',
        type: RelationType.oneToMany,
        target: Terminal,
        isOwningSide: false,
        mappedBy: 'store',
        fetch: RelationFetchStrategy.lazy,
        cascade: const [],
        cascadePersist: false,
        cascadeMerge: false,
        cascadeRemove: false,
      ),
      RelationDescriptor(
        fieldName: 'categories',
        type: RelationType.oneToMany,
        target: Category,
        isOwningSide: false,
        mappedBy: 'store',
        fetch: RelationFetchStrategy.lazy,
        cascade: const [],
        cascadePersist: false,
        cascadeMerge: false,
        cascadeRemove: false,
      ),
      RelationDescriptor(
        fieldName: 'counters',
        type: RelationType.oneToMany,
        target: Counter,
        isOwningSide: false,
        mappedBy: 'store',
        fetch: RelationFetchStrategy.lazy,
        cascade: const [],
        cascadePersist: false,
        cascadeMerge: false,
        cascadeRemove: false,
      ),
      RelationDescriptor(
        fieldName: 'products',
        type: RelationType.oneToMany,
        target: Product,
        isOwningSide: false,
        mappedBy: 'store',
        fetch: RelationFetchStrategy.lazy,
        cascade: const [],
        cascadePersist: false,
        cascadeMerge: false,
        cascadeRemove: false,
      ),
    ],
    uniqueConstraints: const [
      UniqueConstraintDescriptor(columns: ['name', 'merchant_id']),
    ],
    fromRow: (row) => Store(
      id: (row['id'] as String),
      name: (row['name'] as String),
      email: (row['email'] as String),
      whatsappNumber: (row['whatsapp_number'] as String?),
      type: StoreType.values.byName(row['type'] as String),
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
      merchant: null,
      terminals: const <Terminal>[],
      categories: const <Category>[],
      counters: const <Counter>[],
      products: const <Product>[],
    ),
    toRow: (e) => {
      'id': e.id,
      'name': e.name,
      'email': e.email,
      'whatsapp_number': e.whatsappNumber,
      'type': e.type.name,
      'created_at': e.createdAt?.toIso8601String(),
      'updated_at': e.updatedAt?.toIso8601String(),
      'merchant_id': e.merchant?.id,
    },
    fieldsContext: const StoreFieldsContext(),
    repositoryFactory: (EngineAdapter engine) => StoreRepository(engine),
    hooks: EntityHooks<Store>(
      prePersist: (e) {
        e.createdAt = DateTime.now();
        e.updatedAt = DateTime.now();
      },
      preUpdate: (e) {
        e.updatedAt = DateTime.now();
      },
    ),
    defaultSelect: () => StoreSelect(),
  );
}();

class StoreFieldsContext extends QueryFieldsContext<Store> {
  const StoreFieldsContext([super.runtimeContext, super.alias]);

  @override
  StoreFieldsContext bind(QueryRuntimeContext runtimeContext, String alias) =>
      StoreFieldsContext(runtimeContext, alias);

  QueryField<String> get id => field<String>('id');

  QueryField<String> get name => field<String>('name');

  QueryField<String> get email => field<String>('email');

  QueryField<String?> get whatsappNumber => field<String?>('whatsapp_number');

  QueryField<StoreType> get type => field<StoreType>('type');

  QueryField<DateTime?> get createdAt => field<DateTime?>('created_at');

  QueryField<DateTime?> get updatedAt => field<DateTime?>('updated_at');

  QueryField<String?> get merchantId => field<String?>('merchant_id');

  MerchantFieldsContext get merchant {
    final alias = ensureRelationJoin(
      relationName: 'merchant',
      targetTableName: $MerchantEntityDescriptor.qualifiedTableName,
      localColumn: 'merchant_id',
      foreignColumn: 'id',
      joinType: JoinType.left,
    );
    return MerchantFieldsContext(runtimeOrThrow, alias);
  }

  /// Find the owning relation on the target entity to get join column info
  TerminalFieldsContext get terminals {
    final targetRelation = $TerminalEntityDescriptor.relations.firstWhere(
      (r) => r.fieldName == 'store',
    );
    final joinColumn = targetRelation.joinColumn!;
    final alias = ensureRelationJoin(
      relationName: 'terminals',
      targetTableName: $TerminalEntityDescriptor.qualifiedTableName,
      localColumn: joinColumn.referencedColumnName,
      foreignColumn: joinColumn.name,
      joinType: JoinType.left,
    );
    return TerminalFieldsContext(runtimeOrThrow, alias);
  }

  /// Find the owning relation on the target entity to get join column info
  CategoryFieldsContext get categories {
    final targetRelation = $CategoryEntityDescriptor.relations.firstWhere(
      (r) => r.fieldName == 'store',
    );
    final joinColumn = targetRelation.joinColumn!;
    final alias = ensureRelationJoin(
      relationName: 'categories',
      targetTableName: $CategoryEntityDescriptor.qualifiedTableName,
      localColumn: joinColumn.referencedColumnName,
      foreignColumn: joinColumn.name,
      joinType: JoinType.left,
    );
    return CategoryFieldsContext(runtimeOrThrow, alias);
  }

  /// Find the owning relation on the target entity to get join column info
  CounterFieldsContext get counters {
    final targetRelation = $CounterEntityDescriptor.relations.firstWhere(
      (r) => r.fieldName == 'store',
    );
    final joinColumn = targetRelation.joinColumn!;
    final alias = ensureRelationJoin(
      relationName: 'counters',
      targetTableName: $CounterEntityDescriptor.qualifiedTableName,
      localColumn: joinColumn.referencedColumnName,
      foreignColumn: joinColumn.name,
      joinType: JoinType.left,
    );
    return CounterFieldsContext(runtimeOrThrow, alias);
  }

  /// Find the owning relation on the target entity to get join column info
  ProductFieldsContext get products {
    final targetRelation = $ProductEntityDescriptor.relations.firstWhere(
      (r) => r.fieldName == 'store',
    );
    final joinColumn = targetRelation.joinColumn!;
    final alias = ensureRelationJoin(
      relationName: 'products',
      targetTableName: $ProductEntityDescriptor.qualifiedTableName,
      localColumn: joinColumn.referencedColumnName,
      foreignColumn: joinColumn.name,
      joinType: JoinType.left,
    );
    return ProductFieldsContext(runtimeOrThrow, alias);
  }
}

class StoreQuery extends QueryBuilder<Store> {
  const StoreQuery(this._builder);

  final WhereExpression Function(StoreFieldsContext) _builder;

  @override
  WhereExpression build(QueryFieldsContext<Store> context) {
    if (context is! StoreFieldsContext) {
      throw ArgumentError('Expected StoreFieldsContext for StoreQuery');
    }
    return _builder(context);
  }
}

class StoreSelect extends SelectOptions<Store, StorePartial> {
  const StoreSelect({
    this.id = true,
    this.name = true,
    this.email = true,
    this.whatsappNumber = true,
    this.type = true,
    this.createdAt = true,
    this.updatedAt = true,
    this.merchantId = true,
    this.relations,
  });

  final bool id;

  final bool name;

  final bool email;

  final bool whatsappNumber;

  final bool type;

  final bool createdAt;

  final bool updatedAt;

  final bool merchantId;

  final StoreRelations? relations;

  @override
  bool get hasSelections =>
      id ||
      name ||
      email ||
      whatsappNumber ||
      type ||
      createdAt ||
      updatedAt ||
      merchantId ||
      (relations?.hasSelections ?? false);

  @override
  SelectOptions<Store, StorePartial> withRelations(
    RelationsOptions<Store, StorePartial>? relations,
  ) {
    return StoreSelect(
      id: id,
      name: name,
      email: email,
      whatsappNumber: whatsappNumber,
      type: type,
      createdAt: createdAt,
      updatedAt: updatedAt,
      merchantId: merchantId,
      relations: relations as StoreRelations?,
    );
  }

  @override
  void collect(
    QueryFieldsContext<Store> context,
    List<SelectField> out, {
    String? path,
  }) {
    if (context is! StoreFieldsContext) {
      throw ArgumentError('Expected StoreFieldsContext for StoreSelect');
    }
    final StoreFieldsContext scoped = context;
    String? aliasFor(String column) {
      final current = path;
      if (current == null || current.isEmpty) return null;
      return '${current}_$column';
    }

    final tableAlias = scoped.currentAlias;
    if (id) {
      out.add(SelectField('id', tableAlias: tableAlias, alias: aliasFor('id')));
    }
    if (name) {
      out.add(
        SelectField('name', tableAlias: tableAlias, alias: aliasFor('name')),
      );
    }
    if (email) {
      out.add(
        SelectField('email', tableAlias: tableAlias, alias: aliasFor('email')),
      );
    }
    if (whatsappNumber) {
      out.add(
        SelectField(
          'whatsapp_number',
          tableAlias: tableAlias,
          alias: aliasFor('whatsapp_number'),
        ),
      );
    }
    if (type) {
      out.add(
        SelectField('type', tableAlias: tableAlias, alias: aliasFor('type')),
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
    if (merchantId) {
      out.add(
        SelectField(
          'merchant_id',
          tableAlias: tableAlias,
          alias: aliasFor('merchant_id'),
        ),
      );
    }
    final rels = relations;
    if (rels != null && rels.hasSelections) {
      rels.collect(scoped, out, path: path);
    }
  }

  @override
  StorePartial hydrate(Map<String, dynamic> row, {String? path}) {
    MerchantPartial? merchantPartial;
    final merchantSelect = relations?.merchant;
    if (merchantSelect != null && merchantSelect.hasSelections) {
      merchantPartial = merchantSelect.hydrate(
        row,
        path: extendPath(path, 'merchant'),
      );
    }
    // Collection relation terminals requires row aggregation
    // Collection relation categories requires row aggregation
    // Collection relation counters requires row aggregation
    // Collection relation products requires row aggregation
    return StorePartial(
      id: id ? readValue(row, 'id', path: path) as String : null,
      name: name ? readValue(row, 'name', path: path) as String : null,
      email: email ? readValue(row, 'email', path: path) as String : null,
      whatsappNumber: whatsappNumber
          ? readValue(row, 'whatsapp_number', path: path) as String?
          : null,
      type: type
          ? StoreType.values.byName(
              readValue(row, 'type', path: path) as String,
            )
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
      merchantId: merchantId
          ? readValue(row, 'merchant_id', path: path) as String?
          : null,
      merchant: merchantPartial,
      terminals: null,
      categories: null,
      counters: null,
      products: null,
    );
  }

  @override
  bool get hasCollectionRelations => true;

  @override
  String? get primaryKeyColumn => 'id';

  @override
  List<StorePartial> aggregateRows(
    List<Map<String, dynamic>> rows, {
    String? path,
  }) {
    if (rows.isEmpty) return [];
    final grouped = <Object?, List<Map<String, dynamic>>>{};
    for (final row in rows) {
      final key = readValue(row, 'id', path: path);
      (grouped[key] ??= []).add(row);
    }
    return grouped.entries.map((entry) {
      final groupRows = entry.value;
      final firstRow = groupRows.first;
      final base = hydrate(firstRow, path: path);
      // Aggregate terminals collection
      final terminalsSelect = relations?.terminals;
      List<TerminalPartial>? terminalsList;
      if (terminalsSelect != null && terminalsSelect.hasSelections) {
        final relationPath = extendPath(path, 'terminals');
        terminalsList = <TerminalPartial>[];
        final seenKeys = <Object?>{};
        for (final row in groupRows) {
          final itemKey = terminalsSelect.readValue(
            row,
            terminalsSelect.primaryKeyColumn ?? 'id',
            path: relationPath,
          );
          if (itemKey != null && seenKeys.add(itemKey)) {
            terminalsList.add(terminalsSelect.hydrate(row, path: relationPath));
          }
        }
      }
      // Aggregate categories collection
      final categoriesSelect = relations?.categories;
      List<CategoryPartial>? categoriesList;
      if (categoriesSelect != null && categoriesSelect.hasSelections) {
        final relationPath = extendPath(path, 'categories');
        categoriesList = <CategoryPartial>[];
        final seenKeys = <Object?>{};
        for (final row in groupRows) {
          final itemKey = categoriesSelect.readValue(
            row,
            categoriesSelect.primaryKeyColumn ?? 'id',
            path: relationPath,
          );
          if (itemKey != null && seenKeys.add(itemKey)) {
            categoriesList.add(
              categoriesSelect.hydrate(row, path: relationPath),
            );
          }
        }
      }
      // Aggregate counters collection
      final countersSelect = relations?.counters;
      List<CounterPartial>? countersList;
      if (countersSelect != null && countersSelect.hasSelections) {
        final relationPath = extendPath(path, 'counters');
        countersList = <CounterPartial>[];
        final seenKeys = <Object?>{};
        for (final row in groupRows) {
          final itemKey = countersSelect.readValue(
            row,
            countersSelect.primaryKeyColumn ?? 'id',
            path: relationPath,
          );
          if (itemKey != null && seenKeys.add(itemKey)) {
            countersList.add(countersSelect.hydrate(row, path: relationPath));
          }
        }
      }
      // Aggregate products collection
      final productsSelect = relations?.products;
      List<ProductPartial>? productsList;
      if (productsSelect != null && productsSelect.hasSelections) {
        final relationPath = extendPath(path, 'products');
        productsList = <ProductPartial>[];
        final seenKeys = <Object?>{};
        for (final row in groupRows) {
          final itemKey = productsSelect.readValue(
            row,
            productsSelect.primaryKeyColumn ?? 'id',
            path: relationPath,
          );
          if (itemKey != null && seenKeys.add(itemKey)) {
            productsList.add(productsSelect.hydrate(row, path: relationPath));
          }
        }
      }
      return StorePartial(
        id: base.id,
        name: base.name,
        email: base.email,
        whatsappNumber: base.whatsappNumber,
        type: base.type,
        createdAt: base.createdAt,
        updatedAt: base.updatedAt,
        merchantId: base.merchantId,
        merchant: base.merchant,
        terminals: terminalsList,
        categories: categoriesList,
        counters: countersList,
        products: productsList,
      );
    }).toList();
  }
}

class StoreRelations extends RelationsOptions<Store, StorePartial> {
  const StoreRelations({
    this.merchant,
    this.terminals,
    this.categories,
    this.counters,
    this.products,
  });

  final MerchantSelect? merchant;

  final TerminalSelect? terminals;

  final CategorySelect? categories;

  final CounterSelect? counters;

  final ProductSelect? products;

  @override
  bool get hasSelections =>
      (merchant?.hasSelections ?? false) ||
      (terminals?.hasSelections ?? false) ||
      (categories?.hasSelections ?? false) ||
      (counters?.hasSelections ?? false) ||
      (products?.hasSelections ?? false);

  @override
  void collect(
    QueryFieldsContext<Store> context,
    List<SelectField> out, {
    String? path,
  }) {
    if (context is! StoreFieldsContext) {
      throw ArgumentError('Expected StoreFieldsContext for StoreRelations');
    }
    final StoreFieldsContext scoped = context;

    final merchantSelect = merchant;
    if (merchantSelect != null && merchantSelect.hasSelections) {
      final relationPath = path == null || path.isEmpty
          ? 'merchant'
          : '${path}_merchant';
      final relationContext = scoped.merchant;
      merchantSelect.collect(relationContext, out, path: relationPath);
    }
    final terminalsSelect = terminals;
    if (terminalsSelect != null && terminalsSelect.hasSelections) {
      final relationPath = path == null || path.isEmpty
          ? 'terminals'
          : '${path}_terminals';
      final relationContext = scoped.terminals;
      terminalsSelect.collect(relationContext, out, path: relationPath);
    }
    final categoriesSelect = categories;
    if (categoriesSelect != null && categoriesSelect.hasSelections) {
      final relationPath = path == null || path.isEmpty
          ? 'categories'
          : '${path}_categories';
      final relationContext = scoped.categories;
      categoriesSelect.collect(relationContext, out, path: relationPath);
    }
    final countersSelect = counters;
    if (countersSelect != null && countersSelect.hasSelections) {
      final relationPath = path == null || path.isEmpty
          ? 'counters'
          : '${path}_counters';
      final relationContext = scoped.counters;
      countersSelect.collect(relationContext, out, path: relationPath);
    }
    final productsSelect = products;
    if (productsSelect != null && productsSelect.hasSelections) {
      final relationPath = path == null || path.isEmpty
          ? 'products'
          : '${path}_products';
      final relationContext = scoped.products;
      productsSelect.collect(relationContext, out, path: relationPath);
    }
  }
}

class StorePartial extends PartialEntity<Store> {
  const StorePartial({
    this.id,
    this.name,
    this.email,
    this.whatsappNumber,
    this.type,
    this.createdAt,
    this.updatedAt,
    this.merchantId,
    this.merchant,
    this.terminals,
    this.categories,
    this.counters,
    this.products,
  });

  final String? id;

  final String? name;

  final String? email;

  final String? whatsappNumber;

  final StoreType? type;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? merchantId;

  final MerchantPartial? merchant;

  final List<TerminalPartial>? terminals;

  final List<CategoryPartial>? categories;

  final List<CounterPartial>? counters;

  final List<ProductPartial>? products;

  @override
  Object? get primaryKeyValue {
    return id;
  }

  @override
  StoreInsertDto toInsertDto() {
    final missing = <String>[];
    if (name == null) missing.add('name');
    if (email == null) missing.add('email');
    if (type == null) missing.add('type');
    if (missing.isNotEmpty) {
      throw StateError(
        'Cannot convert StorePartial to StoreInsertDto: missing required fields: ${missing.join(', ')}',
      );
    }
    return StoreInsertDto(
      name: name!,
      email: email!,
      whatsappNumber: whatsappNumber,
      type: type!,
      createdAt: createdAt,
      updatedAt: updatedAt,
      merchantId: merchantId,
    );
  }

  @override
  StoreUpdateDto toUpdateDto() {
    return StoreUpdateDto(
      name: name,
      email: email,
      whatsappNumber: whatsappNumber,
      type: type,
      createdAt: createdAt,
      updatedAt: updatedAt,
      merchantId: merchantId,
    );
  }

  @override
  Store toEntity() {
    final missing = <String>[];
    if (id == null) missing.add('id');
    if (name == null) missing.add('name');
    if (email == null) missing.add('email');
    if (type == null) missing.add('type');
    if (missing.isNotEmpty) {
      throw StateError(
        'Cannot convert StorePartial to Store: missing required fields: ${missing.join(', ')}',
      );
    }
    return Store(
      id: id!,
      name: name!,
      email: email!,
      whatsappNumber: whatsappNumber,
      type: type!,
      createdAt: createdAt,
      updatedAt: updatedAt,
      merchant: merchant?.toEntity(),
      terminals:
          terminals?.map((p) => p.toEntity()).toList() ?? const <Terminal>[],
      categories:
          categories?.map((p) => p.toEntity()).toList() ?? const <Category>[],
      counters:
          counters?.map((p) => p.toEntity()).toList() ?? const <Counter>[],
      products:
          products?.map((p) => p.toEntity()).toList() ?? const <Product>[],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (whatsappNumber != null) 'whatsappNumber': whatsappNumber,
      if (type != null) 'type': type?.name,
      if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
      if (merchant != null) 'merchant': merchant?.toJson(),
      if (terminals != null)
        'terminals': terminals?.map((e) => e.toJson()).toList(),
      if (categories != null)
        'categories': categories?.map((e) => e.toJson()).toList(),
      if (counters != null)
        'counters': counters?.map((e) => e.toJson()).toList(),
      if (products != null)
        'products': products?.map((e) => e.toJson()).toList(),
      if (merchantId != null) 'merchantId': merchantId,
    };
  }
}

class StoreInsertDto implements InsertDto<Store> {
  const StoreInsertDto({
    required this.name,
    required this.email,
    this.whatsappNumber,
    required this.type,
    this.createdAt,
    this.updatedAt,
    this.merchantId,
  });

  final String name;

  final String email;

  final String? whatsappNumber;

  final StoreType type;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? merchantId;

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'whatsapp_number': whatsappNumber,
      'type': type.name,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      if (merchantId != null) 'merchant_id': merchantId,
    };
  }

  Map<String, dynamic> get cascades {
    return const {};
  }

  StoreInsertDto copyWith({
    String? name,
    String? email,
    String? whatsappNumber,
    StoreType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? merchantId,
  }) {
    return StoreInsertDto(
      name: name ?? this.name,
      email: email ?? this.email,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      merchantId: merchantId ?? this.merchantId,
    );
  }
}

class StoreUpdateDto implements UpdateDto<Store> {
  const StoreUpdateDto({
    this.name,
    this.email,
    this.whatsappNumber,
    this.type,
    this.createdAt,
    this.updatedAt,
    this.merchantId,
  });

  final String? name;

  final String? email;

  final String? whatsappNumber;

  final StoreType? type;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? merchantId;

  @override
  Map<String, dynamic> toMap() {
    return {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (whatsappNumber != null) 'whatsapp_number': whatsappNumber,
      if (type != null) 'type': type?.name,
      if (createdAt != null)
        'created_at': createdAt is DateTime
            ? (createdAt as DateTime).toIso8601String()
            : createdAt?.toString(),
      'updated_at': DateTime.now().toIso8601String(),
      if (merchantId != null) 'merchant_id': merchantId,
    };
  }

  Map<String, dynamic> get cascades {
    return const {};
  }
}

class StoreRepository extends EntityRepository<Store, StorePartial> {
  StoreRepository(EngineAdapter engine)
    : super(
        $StoreEntityDescriptor,
        engine,
        $StoreEntityDescriptor.fieldsContext,
      );
}

extension StoreJson on Store {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (whatsappNumber != null) 'whatsappNumber': whatsappNumber,
      'type': type.name,
      if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
      if (merchant != null) 'merchant': merchant?.toJson(),
      if (terminals != null)
        'terminals': terminals?.map((e) => e.toJson()).toList(),
      if (categories != null)
        'categories': categories?.map((e) => e.toJson()).toList(),
      if (counters != null)
        'counters': counters?.map((e) => e.toJson()).toList(),
      if (products != null)
        'products': products?.map((e) => e.toJson()).toList(),
    };
  }
}

extension StoreCodec on Store {
  Object? toEncodable() {
    return toJson();
  }

  String toJsonString() {
    return encodeJsonColumn(toJson()) as String;
  }
}

extension StorePartialCodec on StorePartial {
  Object? toEncodable() {
    return toJson();
  }

  String toJsonString() {
    return encodeJsonColumn(toJson()) as String;
  }
}

var $isStoreJsonCodecInitialized = false;
void $initStoreJsonCodec() {
  if ($isStoreJsonCodecInitialized) return;
  EntityJsonRegistry.register<Store>((value) => StoreJson(value).toJson());
  $isStoreJsonCodecInitialized = true;
}

extension StoreRepositoryExtensions
    on EntityRepository<Store, PartialEntity<Store>> {}
