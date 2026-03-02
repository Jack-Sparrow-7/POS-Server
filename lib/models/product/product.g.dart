// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// LoxiaEntityGenerator
// **************************************************************************

final EntityDescriptor<Product, ProductPartial> $ProductEntityDescriptor = () {
  $initProductJsonCodec();
  return EntityDescriptor(
    entityType: Product,
    tableName: 'products',
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
        name: 'description',
        propertyName: 'description',
        type: ColumnType.text,
        nullable: true,
        unique: false,
        isPrimaryKey: false,
        autoIncrement: false,
        uuid: false,
        isDeletedAt: false,
      ),
      ColumnDescriptor(
        name: 'base_price',
        propertyName: 'basePrice',
        type: ColumnType.integer,
        nullable: false,
        unique: false,
        isPrimaryKey: false,
        autoIncrement: false,
        uuid: false,
        isDeletedAt: false,
      ),
      ColumnDescriptor(
        name: 'selling_price',
        propertyName: 'sellingPrice',
        type: ColumnType.integer,
        nullable: false,
        unique: false,
        isPrimaryKey: false,
        autoIncrement: false,
        uuid: false,
        isDeletedAt: false,
      ),
      ColumnDescriptor(
        name: 'sku',
        propertyName: 'sku',
        type: ColumnType.text,
        nullable: true,
        unique: false,
        isPrimaryKey: false,
        autoIncrement: false,
        uuid: false,
        isDeletedAt: false,
      ),
      ColumnDescriptor(
        name: 'image_url',
        propertyName: 'imageUrl',
        type: ColumnType.text,
        nullable: true,
        unique: false,
        isPrimaryKey: false,
        autoIncrement: false,
        uuid: false,
        isDeletedAt: false,
      ),
      ColumnDescriptor(
        name: 'is_active',
        propertyName: 'isActive',
        type: ColumnType.boolean,
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
        fieldName: 'category',
        type: RelationType.manyToOne,
        target: Category,
        isOwningSide: true,
        fetch: RelationFetchStrategy.lazy,
        cascade: const [],
        cascadePersist: false,
        cascadeMerge: false,
        cascadeRemove: false,
        joinColumn: JoinColumnDescriptor(
          name: 'category_id',
          referencedColumnName: 'id',
          nullable: true,
          unique: false,
        ),
      ),
      RelationDescriptor(
        fieldName: 'counter',
        type: RelationType.manyToOne,
        target: Counter,
        isOwningSide: true,
        fetch: RelationFetchStrategy.lazy,
        cascade: const [],
        cascadePersist: false,
        cascadeMerge: false,
        cascadeRemove: false,
        joinColumn: JoinColumnDescriptor(
          name: 'counter_id',
          referencedColumnName: 'id',
          nullable: true,
          unique: false,
        ),
      ),
    ],
    uniqueConstraints: const [
      UniqueConstraintDescriptor(columns: ['name', 'store_id']),
    ],
    fromRow: (row) => Product(
      id: (row['id'] as String),
      name: (row['name'] as String),
      description: (row['description'] as String?),
      basePrice: (row['base_price'] as int),
      sellingPrice: (row['selling_price'] as int),
      sku: (row['sku'] as String?),
      imageUrl: (row['image_url'] as String?),
      isActive: row['is_active'] == 1,
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
      store: null,
      category: null,
      counter: null,
    ),
    toRow: (e) => {
      'id': e.id,
      'name': e.name,
      'description': e.description,
      'base_price': e.basePrice,
      'selling_price': e.sellingPrice,
      'sku': e.sku,
      'image_url': e.imageUrl,
      'is_active': e.isActive,
      'created_at': e.createdAt?.toIso8601String(),
      'updated_at': e.updatedAt?.toIso8601String(),
      'store_id': e.store?.id,
      'category_id': e.category?.id,
      'counter_id': e.counter?.id,
    },
    fieldsContext: const ProductFieldsContext(),
    repositoryFactory: (EngineAdapter engine) => ProductRepository(engine),
    hooks: EntityHooks<Product>(
      prePersist: (e) {
        e.createdAt = DateTime.now();
        e.updatedAt = DateTime.now();
      },
      preUpdate: (e) {
        e.updatedAt = DateTime.now();
      },
    ),
    defaultSelect: () => ProductSelect(),
  );
}();

class ProductFieldsContext extends QueryFieldsContext<Product> {
  const ProductFieldsContext([super.runtimeContext, super.alias]);

  @override
  ProductFieldsContext bind(QueryRuntimeContext runtimeContext, String alias) =>
      ProductFieldsContext(runtimeContext, alias);

  QueryField<String> get id => field<String>('id');

  QueryField<String> get name => field<String>('name');

  QueryField<String?> get description => field<String?>('description');

  QueryField<int> get basePrice => field<int>('base_price');

  QueryField<int> get sellingPrice => field<int>('selling_price');

  QueryField<String?> get sku => field<String?>('sku');

  QueryField<String?> get imageUrl => field<String?>('image_url');

  QueryField<bool> get isActive => field<bool>('is_active');

  QueryField<DateTime?> get createdAt => field<DateTime?>('created_at');

  QueryField<DateTime?> get updatedAt => field<DateTime?>('updated_at');

  QueryField<String?> get storeId => field<String?>('store_id');

  QueryField<String?> get categoryId => field<String?>('category_id');

  QueryField<String?> get counterId => field<String?>('counter_id');

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

  CategoryFieldsContext get category {
    final alias = ensureRelationJoin(
      relationName: 'category',
      targetTableName: $CategoryEntityDescriptor.qualifiedTableName,
      localColumn: 'category_id',
      foreignColumn: 'id',
      joinType: JoinType.left,
    );
    return CategoryFieldsContext(runtimeOrThrow, alias);
  }

  CounterFieldsContext get counter {
    final alias = ensureRelationJoin(
      relationName: 'counter',
      targetTableName: $CounterEntityDescriptor.qualifiedTableName,
      localColumn: 'counter_id',
      foreignColumn: 'id',
      joinType: JoinType.left,
    );
    return CounterFieldsContext(runtimeOrThrow, alias);
  }
}

class ProductQuery extends QueryBuilder<Product> {
  const ProductQuery(this._builder);

  final WhereExpression Function(ProductFieldsContext) _builder;

  @override
  WhereExpression build(QueryFieldsContext<Product> context) {
    if (context is! ProductFieldsContext) {
      throw ArgumentError('Expected ProductFieldsContext for ProductQuery');
    }
    return _builder(context);
  }
}

class ProductSelect extends SelectOptions<Product, ProductPartial> {
  const ProductSelect({
    this.id = true,
    this.name = true,
    this.description = true,
    this.basePrice = true,
    this.sellingPrice = true,
    this.sku = true,
    this.imageUrl = true,
    this.isActive = true,
    this.createdAt = true,
    this.updatedAt = true,
    this.storeId = true,
    this.categoryId = true,
    this.counterId = true,
    this.relations,
  });

  final bool id;

  final bool name;

  final bool description;

  final bool basePrice;

  final bool sellingPrice;

  final bool sku;

  final bool imageUrl;

  final bool isActive;

  final bool createdAt;

  final bool updatedAt;

  final bool storeId;

  final bool categoryId;

  final bool counterId;

  final ProductRelations? relations;

  @override
  bool get hasSelections =>
      id ||
      name ||
      description ||
      basePrice ||
      sellingPrice ||
      sku ||
      imageUrl ||
      isActive ||
      createdAt ||
      updatedAt ||
      storeId ||
      categoryId ||
      counterId ||
      (relations?.hasSelections ?? false);

  @override
  SelectOptions<Product, ProductPartial> withRelations(
    RelationsOptions<Product, ProductPartial>? relations,
  ) {
    return ProductSelect(
      id: id,
      name: name,
      description: description,
      basePrice: basePrice,
      sellingPrice: sellingPrice,
      sku: sku,
      imageUrl: imageUrl,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      storeId: storeId,
      categoryId: categoryId,
      counterId: counterId,
      relations: relations as ProductRelations?,
    );
  }

  @override
  void collect(
    QueryFieldsContext<Product> context,
    List<SelectField> out, {
    String? path,
  }) {
    if (context is! ProductFieldsContext) {
      throw ArgumentError('Expected ProductFieldsContext for ProductSelect');
    }
    final ProductFieldsContext scoped = context;
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
    if (description) {
      out.add(
        SelectField(
          'description',
          tableAlias: tableAlias,
          alias: aliasFor('description'),
        ),
      );
    }
    if (basePrice) {
      out.add(
        SelectField(
          'base_price',
          tableAlias: tableAlias,
          alias: aliasFor('base_price'),
        ),
      );
    }
    if (sellingPrice) {
      out.add(
        SelectField(
          'selling_price',
          tableAlias: tableAlias,
          alias: aliasFor('selling_price'),
        ),
      );
    }
    if (sku) {
      out.add(
        SelectField('sku', tableAlias: tableAlias, alias: aliasFor('sku')),
      );
    }
    if (imageUrl) {
      out.add(
        SelectField(
          'image_url',
          tableAlias: tableAlias,
          alias: aliasFor('image_url'),
        ),
      );
    }
    if (isActive) {
      out.add(
        SelectField(
          'is_active',
          tableAlias: tableAlias,
          alias: aliasFor('is_active'),
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
    if (storeId) {
      out.add(
        SelectField(
          'store_id',
          tableAlias: tableAlias,
          alias: aliasFor('store_id'),
        ),
      );
    }
    if (categoryId) {
      out.add(
        SelectField(
          'category_id',
          tableAlias: tableAlias,
          alias: aliasFor('category_id'),
        ),
      );
    }
    if (counterId) {
      out.add(
        SelectField(
          'counter_id',
          tableAlias: tableAlias,
          alias: aliasFor('counter_id'),
        ),
      );
    }
    final rels = relations;
    if (rels != null && rels.hasSelections) {
      rels.collect(scoped, out, path: path);
    }
  }

  @override
  ProductPartial hydrate(Map<String, dynamic> row, {String? path}) {
    StorePartial? storePartial;
    final storeSelect = relations?.store;
    if (storeSelect != null && storeSelect.hasSelections) {
      storePartial = storeSelect.hydrate(row, path: extendPath(path, 'store'));
    }
    CategoryPartial? categoryPartial;
    final categorySelect = relations?.category;
    if (categorySelect != null && categorySelect.hasSelections) {
      categoryPartial = categorySelect.hydrate(
        row,
        path: extendPath(path, 'category'),
      );
    }
    CounterPartial? counterPartial;
    final counterSelect = relations?.counter;
    if (counterSelect != null && counterSelect.hasSelections) {
      counterPartial = counterSelect.hydrate(
        row,
        path: extendPath(path, 'counter'),
      );
    }
    return ProductPartial(
      id: id ? readValue(row, 'id', path: path) as String : null,
      name: name ? readValue(row, 'name', path: path) as String : null,
      description: description
          ? readValue(row, 'description', path: path) as String?
          : null,
      basePrice: basePrice
          ? readValue(row, 'base_price', path: path) as int
          : null,
      sellingPrice: sellingPrice
          ? readValue(row, 'selling_price', path: path) as int
          : null,
      sku: sku ? readValue(row, 'sku', path: path) as String? : null,
      imageUrl: imageUrl
          ? readValue(row, 'image_url', path: path) as String?
          : null,
      isActive: isActive
          ? readValue(row, 'is_active', path: path) as bool
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
      storeId: storeId
          ? readValue(row, 'store_id', path: path) as String?
          : null,
      store: storePartial,
      categoryId: categoryId
          ? readValue(row, 'category_id', path: path) as String?
          : null,
      category: categoryPartial,
      counterId: counterId
          ? readValue(row, 'counter_id', path: path) as String?
          : null,
      counter: counterPartial,
    );
  }

  @override
  bool get hasCollectionRelations => false;

  @override
  String? get primaryKeyColumn => 'id';
}

class ProductRelations extends RelationsOptions<Product, ProductPartial> {
  const ProductRelations({this.store, this.category, this.counter});

  final StoreSelect? store;

  final CategorySelect? category;

  final CounterSelect? counter;

  @override
  bool get hasSelections =>
      (store?.hasSelections ?? false) ||
      (category?.hasSelections ?? false) ||
      (counter?.hasSelections ?? false);

  @override
  void collect(
    QueryFieldsContext<Product> context,
    List<SelectField> out, {
    String? path,
  }) {
    if (context is! ProductFieldsContext) {
      throw ArgumentError('Expected ProductFieldsContext for ProductRelations');
    }
    final ProductFieldsContext scoped = context;

    final storeSelect = store;
    if (storeSelect != null && storeSelect.hasSelections) {
      final relationPath = path == null || path.isEmpty
          ? 'store'
          : '${path}_store';
      final relationContext = scoped.store;
      storeSelect.collect(relationContext, out, path: relationPath);
    }
    final categorySelect = category;
    if (categorySelect != null && categorySelect.hasSelections) {
      final relationPath = path == null || path.isEmpty
          ? 'category'
          : '${path}_category';
      final relationContext = scoped.category;
      categorySelect.collect(relationContext, out, path: relationPath);
    }
    final counterSelect = counter;
    if (counterSelect != null && counterSelect.hasSelections) {
      final relationPath = path == null || path.isEmpty
          ? 'counter'
          : '${path}_counter';
      final relationContext = scoped.counter;
      counterSelect.collect(relationContext, out, path: relationPath);
    }
  }
}

class ProductPartial extends PartialEntity<Product> {
  const ProductPartial({
    this.id,
    this.name,
    this.description,
    this.basePrice,
    this.sellingPrice,
    this.sku,
    this.imageUrl,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.storeId,
    this.store,
    this.categoryId,
    this.category,
    this.counterId,
    this.counter,
  });

  final String? id;

  final String? name;

  final String? description;

  final int? basePrice;

  final int? sellingPrice;

  final String? sku;

  final String? imageUrl;

  final bool? isActive;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? storeId;

  final String? categoryId;

  final String? counterId;

  final StorePartial? store;

  final CategoryPartial? category;

  final CounterPartial? counter;

  @override
  Object? get primaryKeyValue {
    return id;
  }

  @override
  ProductInsertDto toInsertDto() {
    final missing = <String>[];
    if (name == null) missing.add('name');
    if (basePrice == null) missing.add('basePrice');
    if (sellingPrice == null) missing.add('sellingPrice');
    if (isActive == null) missing.add('isActive');
    if (missing.isNotEmpty) {
      throw StateError(
        'Cannot convert ProductPartial to ProductInsertDto: missing required fields: ${missing.join(', ')}',
      );
    }
    return ProductInsertDto(
      name: name!,
      description: description,
      basePrice: basePrice!,
      sellingPrice: sellingPrice!,
      sku: sku,
      imageUrl: imageUrl,
      isActive: isActive!,
      createdAt: createdAt,
      updatedAt: updatedAt,
      storeId: storeId,
      categoryId: categoryId,
      counterId: counterId,
    );
  }

  @override
  ProductUpdateDto toUpdateDto() {
    return ProductUpdateDto(
      name: name,
      description: description,
      basePrice: basePrice,
      sellingPrice: sellingPrice,
      sku: sku,
      imageUrl: imageUrl,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      storeId: storeId,
      categoryId: categoryId,
      counterId: counterId,
    );
  }

  @override
  Product toEntity() {
    final missing = <String>[];
    if (id == null) missing.add('id');
    if (name == null) missing.add('name');
    if (basePrice == null) missing.add('basePrice');
    if (sellingPrice == null) missing.add('sellingPrice');
    if (isActive == null) missing.add('isActive');
    if (missing.isNotEmpty) {
      throw StateError(
        'Cannot convert ProductPartial to Product: missing required fields: ${missing.join(', ')}',
      );
    }
    return Product(
      id: id!,
      name: name!,
      description: description,
      basePrice: basePrice!,
      sellingPrice: sellingPrice!,
      sku: sku,
      imageUrl: imageUrl,
      isActive: isActive!,
      createdAt: createdAt,
      updatedAt: updatedAt,
      store: store?.toEntity(),
      category: category?.toEntity(),
      counter: counter?.toEntity(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (basePrice != null) 'basePrice': basePrice,
      if (sellingPrice != null) 'sellingPrice': sellingPrice,
      if (sku != null) 'sku': sku,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (isActive != null) 'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
      if (store != null) 'store': store?.toJson(),
      if (category != null) 'category': category?.toJson(),
      if (counter != null) 'counter': counter?.toJson(),
      if (storeId != null) 'storeId': storeId,
      if (categoryId != null) 'categoryId': categoryId,
      if (counterId != null) 'counterId': counterId,
    };
  }
}

class ProductInsertDto implements InsertDto<Product> {
  const ProductInsertDto({
    required this.name,
    this.description,
    required this.basePrice,
    required this.sellingPrice,
    this.sku,
    this.imageUrl,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.storeId,
    this.categoryId,
    this.counterId,
  });

  final String name;

  final String? description;

  final int basePrice;

  final int sellingPrice;

  final String? sku;

  final String? imageUrl;

  final bool isActive;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? storeId;

  final String? categoryId;

  final String? counterId;

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'base_price': basePrice,
      'selling_price': sellingPrice,
      'sku': sku,
      'image_url': imageUrl,
      'is_active': isActive,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      if (storeId != null) 'store_id': storeId,
      if (categoryId != null) 'category_id': categoryId,
      if (counterId != null) 'counter_id': counterId,
    };
  }

  Map<String, dynamic> get cascades {
    return const {};
  }

  ProductInsertDto copyWith({
    String? name,
    String? description,
    int? basePrice,
    int? sellingPrice,
    String? sku,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? storeId,
    String? categoryId,
    String? counterId,
  }) {
    return ProductInsertDto(
      name: name ?? this.name,
      description: description ?? this.description,
      basePrice: basePrice ?? this.basePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      sku: sku ?? this.sku,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      storeId: storeId ?? this.storeId,
      categoryId: categoryId ?? this.categoryId,
      counterId: counterId ?? this.counterId,
    );
  }
}

class ProductUpdateDto implements UpdateDto<Product> {
  const ProductUpdateDto({
    this.name,
    this.description,
    this.basePrice,
    this.sellingPrice,
    this.sku,
    this.imageUrl,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.storeId,
    this.categoryId,
    this.counterId,
  });

  final String? name;

  final String? description;

  final int? basePrice;

  final int? sellingPrice;

  final String? sku;

  final String? imageUrl;

  final bool? isActive;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? storeId;

  final String? categoryId;

  final String? counterId;

  @override
  Map<String, dynamic> toMap() {
    return {
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (basePrice != null) 'base_price': basePrice,
      if (sellingPrice != null) 'selling_price': sellingPrice,
      if (sku != null) 'sku': sku,
      if (imageUrl != null) 'image_url': imageUrl,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null)
        'created_at': createdAt is DateTime
            ? (createdAt as DateTime).toIso8601String()
            : createdAt?.toString(),
      'updated_at': DateTime.now().toIso8601String(),
      if (storeId != null) 'store_id': storeId,
      if (categoryId != null) 'category_id': categoryId,
      if (counterId != null) 'counter_id': counterId,
    };
  }

  Map<String, dynamic> get cascades {
    return const {};
  }
}

class ProductRepository extends EntityRepository<Product, ProductPartial> {
  ProductRepository(EngineAdapter engine)
    : super(
        $ProductEntityDescriptor,
        engine,
        $ProductEntityDescriptor.fieldsContext,
      );
}

extension ProductJson on Product {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      'basePrice': basePrice,
      'sellingPrice': sellingPrice,
      if (sku != null) 'sku': sku,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
      if (store != null) 'store': store?.toJson(),
      if (category != null) 'category': category?.toJson(),
      if (counter != null) 'counter': counter?.toJson(),
    };
  }
}

extension ProductCodec on Product {
  Object? toEncodable() {
    return toJson();
  }

  String toJsonString() {
    return encodeJsonColumn(toJson()) as String;
  }
}

extension ProductPartialCodec on ProductPartial {
  Object? toEncodable() {
    return toJson();
  }

  String toJsonString() {
    return encodeJsonColumn(toJson()) as String;
  }
}

var $isProductJsonCodecInitialized = false;
void $initProductJsonCodec() {
  if ($isProductJsonCodecInitialized) return;
  EntityJsonRegistry.register<Product>((value) => ProductJson(value).toJson());
  $isProductJsonCodecInitialized = true;
}

extension ProductRepositoryExtensions
    on EntityRepository<Product, PartialEntity<Product>> {}
