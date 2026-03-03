// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// LoxiaEntityGenerator
// **************************************************************************

final EntityDescriptor<Category, CategoryPartial> $CategoryEntityDescriptor =
    () {
      $initCategoryJsonCodec();
      return EntityDescriptor(
        entityType: Category,
        tableName: 'categories',
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
          ColumnDescriptor(
            name: 'deleted_at',
            propertyName: 'deletedAt',
            type: ColumnType.dateTime,
            nullable: true,
            unique: false,
            isPrimaryKey: false,
            autoIncrement: false,
            uuid: false,
            isDeletedAt: true,
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
        ],
        uniqueConstraints: const [
          UniqueConstraintDescriptor(columns: ['name', 'store_id']),
        ],
        fromRow: (row) => Category(
          id: (row['id'] as String),
          name: (row['name'] as String),
          description: (row['description'] as String?),
          imageUrl: (row['image_url'] as String?),
          isActive: row['is_active'] is bool
              ? row['is_active']
              : row['is_active'] == 1,
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
          deletedAt: row['deleted_at'] == null
              ? null
              : row['deleted_at'] is String
              ? DateTime.parse(row['deleted_at'].toString())
              : row['deleted_at'] as DateTime,
          store: null,
        ),
        toRow: (e) => {
          'id': e.id,
          'name': e.name,
          'description': e.description,
          'image_url': e.imageUrl,
          'is_active': e.isActive,
          'created_at': e.createdAt?.toIso8601String(),
          'updated_at': e.updatedAt?.toIso8601String(),
          'deleted_at': e.deletedAt?.toIso8601String(),
          'store_id': e.store?.id,
        },
        fieldsContext: const CategoryFieldsContext(),
        repositoryFactory: (EngineAdapter engine) => CategoryRepository(engine),
        hooks: EntityHooks<Category>(
          prePersist: (e) {
            e.createdAt = DateTime.now();
            e.updatedAt = DateTime.now();
          },
          preUpdate: (e) {
            e.updatedAt = DateTime.now();
          },
        ),
        defaultSelect: () => CategorySelect(),
      );
    }();

class CategoryFieldsContext extends QueryFieldsContext<Category> {
  const CategoryFieldsContext([super.runtimeContext, super.alias]);

  @override
  CategoryFieldsContext bind(
    QueryRuntimeContext runtimeContext,
    String alias,
  ) => CategoryFieldsContext(runtimeContext, alias);

  QueryField<String> get id => field<String>('id');

  QueryField<String> get name => field<String>('name');

  QueryField<String?> get description => field<String?>('description');

  QueryField<String?> get imageUrl => field<String?>('image_url');

  QueryField<bool> get isActive => field<bool>('is_active');

  QueryField<DateTime?> get createdAt => field<DateTime?>('created_at');

  QueryField<DateTime?> get updatedAt => field<DateTime?>('updated_at');

  QueryField<DateTime?> get deletedAt => field<DateTime?>('deleted_at');

  QueryField<String?> get storeId => field<String?>('store_id');

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

class CategoryQuery extends QueryBuilder<Category> {
  const CategoryQuery(this._builder);

  final WhereExpression Function(CategoryFieldsContext) _builder;

  @override
  WhereExpression build(QueryFieldsContext<Category> context) {
    if (context is! CategoryFieldsContext) {
      throw ArgumentError('Expected CategoryFieldsContext for CategoryQuery');
    }
    return _builder(context);
  }
}

class CategorySelect extends SelectOptions<Category, CategoryPartial> {
  const CategorySelect({
    this.id = true,
    this.name = true,
    this.description = true,
    this.imageUrl = true,
    this.isActive = true,
    this.createdAt = true,
    this.updatedAt = true,
    this.deletedAt = true,
    this.storeId = true,
    this.relations,
  });

  final bool id;

  final bool name;

  final bool description;

  final bool imageUrl;

  final bool isActive;

  final bool createdAt;

  final bool updatedAt;

  final bool deletedAt;

  final bool storeId;

  final CategoryRelations? relations;

  @override
  bool get hasSelections =>
      id ||
      name ||
      description ||
      imageUrl ||
      isActive ||
      createdAt ||
      updatedAt ||
      deletedAt ||
      storeId ||
      (relations?.hasSelections ?? false);

  @override
  SelectOptions<Category, CategoryPartial> withRelations(
    RelationsOptions<Category, CategoryPartial>? relations,
  ) {
    return CategorySelect(
      id: id,
      name: name,
      description: description,
      imageUrl: imageUrl,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      storeId: storeId,
      relations: relations as CategoryRelations?,
    );
  }

  @override
  void collect(
    QueryFieldsContext<Category> context,
    List<SelectField> out, {
    String? path,
  }) {
    if (context is! CategoryFieldsContext) {
      throw ArgumentError('Expected CategoryFieldsContext for CategorySelect');
    }
    final CategoryFieldsContext scoped = context;
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
    if (deletedAt) {
      out.add(
        SelectField(
          'deleted_at',
          tableAlias: tableAlias,
          alias: aliasFor('deleted_at'),
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
  CategoryPartial hydrate(Map<String, dynamic> row, {String? path}) {
    StorePartial? storePartial;
    final storeSelect = relations?.store;
    if (storeSelect != null && storeSelect.hasSelections) {
      storePartial = storeSelect.hydrate(row, path: extendPath(path, 'store'));
    }
    return CategoryPartial(
      id: id ? readValue(row, 'id', path: path) as String : null,
      name: name ? readValue(row, 'name', path: path) as String : null,
      description: description
          ? readValue(row, 'description', path: path) as String?
          : null,
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
      deletedAt: deletedAt
          ? readValue(row, 'deleted_at', path: path) == null
                ? null
                : (readValue(row, 'deleted_at', path: path) is String
                      ? DateTime.parse(
                          readValue(row, 'deleted_at', path: path) as String,
                        )
                      : readValue(row, 'deleted_at', path: path) as DateTime)
          : null,
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

class CategoryRelations extends RelationsOptions<Category, CategoryPartial> {
  const CategoryRelations({this.store});

  final StoreSelect? store;

  @override
  bool get hasSelections => (store?.hasSelections ?? false);

  @override
  void collect(
    QueryFieldsContext<Category> context,
    List<SelectField> out, {
    String? path,
  }) {
    if (context is! CategoryFieldsContext) {
      throw ArgumentError(
        'Expected CategoryFieldsContext for CategoryRelations',
      );
    }
    final CategoryFieldsContext scoped = context;

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

class CategoryPartial extends PartialEntity<Category> {
  const CategoryPartial({
    this.id,
    this.name,
    this.description,
    this.imageUrl,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.storeId,
    this.store,
  });

  final String? id;

  final String? name;

  final String? description;

  final String? imageUrl;

  final bool? isActive;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final DateTime? deletedAt;

  final String? storeId;

  final StorePartial? store;

  @override
  Object? get primaryKeyValue {
    return id;
  }

  @override
  CategoryInsertDto toInsertDto() {
    final missing = <String>[];
    if (name == null) missing.add('name');
    if (isActive == null) missing.add('isActive');
    if (missing.isNotEmpty) {
      throw StateError(
        'Cannot convert CategoryPartial to CategoryInsertDto: missing required fields: ${missing.join(', ')}',
      );
    }
    return CategoryInsertDto(
      name: name!,
      description: description,
      imageUrl: imageUrl,
      isActive: isActive!,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      storeId: storeId,
    );
  }

  @override
  CategoryUpdateDto toUpdateDto() {
    return CategoryUpdateDto(
      name: name,
      description: description,
      imageUrl: imageUrl,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      storeId: storeId,
    );
  }

  @override
  Category toEntity() {
    final missing = <String>[];
    if (id == null) missing.add('id');
    if (name == null) missing.add('name');
    if (isActive == null) missing.add('isActive');
    if (missing.isNotEmpty) {
      throw StateError(
        'Cannot convert CategoryPartial to Category: missing required fields: ${missing.join(', ')}',
      );
    }
    return Category(
      id: id!,
      name: name!,
      description: description,
      imageUrl: imageUrl,
      isActive: isActive!,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      store: store?.toEntity(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (isActive != null) 'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
      if (deletedAt != null) 'deletedAt': deletedAt?.toIso8601String(),
      if (store != null) 'store': store?.toJson(),
      if (storeId != null) 'storeId': storeId,
    };
  }
}

class CategoryInsertDto implements InsertDto<Category> {
  const CategoryInsertDto({
    required this.name,
    this.description,
    this.imageUrl,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.storeId,
  });

  final String name;

  final String? description;

  final String? imageUrl;

  final bool isActive;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final DateTime? deletedAt;

  final String? storeId;

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'is_active': isActive,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'deleted_at': deletedAt is DateTime
          ? (deletedAt as DateTime).toIso8601String()
          : deletedAt?.toString(),
      if (storeId != null) 'store_id': storeId,
    };
  }

  Map<String, dynamic> get cascades {
    return const {};
  }

  CategoryInsertDto copyWith({
    String? name,
    String? description,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? storeId,
  }) {
    return CategoryInsertDto(
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      storeId: storeId ?? this.storeId,
    );
  }
}

class CategoryUpdateDto implements UpdateDto<Category> {
  const CategoryUpdateDto({
    this.name,
    this.description,
    this.imageUrl,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.storeId,
  });

  final String? name;

  final String? description;

  final String? imageUrl;

  final bool? isActive;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final DateTime? deletedAt;

  final String? storeId;

  @override
  Map<String, dynamic> toMap() {
    return {
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (imageUrl != null) 'image_url': imageUrl,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null)
        'created_at': createdAt is DateTime
            ? (createdAt as DateTime).toIso8601String()
            : createdAt?.toString(),
      'updated_at': DateTime.now().toIso8601String(),
      if (deletedAt != null)
        'deleted_at': deletedAt is DateTime
            ? (deletedAt as DateTime).toIso8601String()
            : deletedAt?.toString(),
      if (storeId != null) 'store_id': storeId,
    };
  }

  Map<String, dynamic> get cascades {
    return const {};
  }
}

class CategoryRepository extends EntityRepository<Category, CategoryPartial> {
  CategoryRepository(EngineAdapter engine)
    : super(
        $CategoryEntityDescriptor,
        engine,
        $CategoryEntityDescriptor.fieldsContext,
      );
}

extension CategoryJson on Category {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
      if (deletedAt != null) 'deletedAt': deletedAt?.toIso8601String(),
      if (store != null) 'store': store?.toJson(),
    };
  }
}

extension CategoryCodec on Category {
  Object? toEncodable() {
    return toJson();
  }

  String toJsonString() {
    return encodeJsonColumn(toJson()) as String;
  }
}

extension CategoryPartialCodec on CategoryPartial {
  Object? toEncodable() {
    return toJson();
  }

  String toJsonString() {
    return encodeJsonColumn(toJson()) as String;
  }
}

var $isCategoryJsonCodecInitialized = false;
void $initCategoryJsonCodec() {
  if ($isCategoryJsonCodecInitialized) return;
  EntityJsonRegistry.register<Category>(
    (value) => CategoryJson(value).toJson(),
  );
  $isCategoryJsonCodecInitialized = true;
}

extension CategoryRepositoryExtensions
    on EntityRepository<Category, PartialEntity<Category>> {}
