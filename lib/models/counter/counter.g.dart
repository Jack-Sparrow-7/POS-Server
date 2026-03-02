// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'counter.dart';

// **************************************************************************
// LoxiaEntityGenerator
// **************************************************************************

final EntityDescriptor<Counter, CounterPartial> $CounterEntityDescriptor = () {
  $initCounterJsonCodec();
  return EntityDescriptor(
    entityType: Counter,
    tableName: 'counters',
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
    ],
    uniqueConstraints: const [
      UniqueConstraintDescriptor(columns: ['name', 'store_id']),
    ],
    fromRow: (row) => Counter(
      id: (row['id'] as String),
      name: (row['name'] as String),
      description: (row['description'] as String?),
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
    ),
    toRow: (e) => {
      'id': e.id,
      'name': e.name,
      'description': e.description,
      'is_active': e.isActive,
      'created_at': e.createdAt?.toIso8601String(),
      'updated_at': e.updatedAt?.toIso8601String(),
      'store_id': e.store?.id,
    },
    fieldsContext: const CounterFieldsContext(),
    repositoryFactory: (EngineAdapter engine) => CounterRepository(engine),
    hooks: EntityHooks<Counter>(
      prePersist: (e) {
        e.createdAt = DateTime.now();
        e.updatedAt = DateTime.now();
      },
      preUpdate: (e) {
        e.updatedAt = DateTime.now();
      },
    ),
    defaultSelect: () => CounterSelect(),
  );
}();

class CounterFieldsContext extends QueryFieldsContext<Counter> {
  const CounterFieldsContext([super.runtimeContext, super.alias]);

  @override
  CounterFieldsContext bind(QueryRuntimeContext runtimeContext, String alias) =>
      CounterFieldsContext(runtimeContext, alias);

  QueryField<String> get id => field<String>('id');

  QueryField<String> get name => field<String>('name');

  QueryField<String?> get description => field<String?>('description');

  QueryField<bool> get isActive => field<bool>('is_active');

  QueryField<DateTime?> get createdAt => field<DateTime?>('created_at');

  QueryField<DateTime?> get updatedAt => field<DateTime?>('updated_at');

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

class CounterQuery extends QueryBuilder<Counter> {
  const CounterQuery(this._builder);

  final WhereExpression Function(CounterFieldsContext) _builder;

  @override
  WhereExpression build(QueryFieldsContext<Counter> context) {
    if (context is! CounterFieldsContext) {
      throw ArgumentError('Expected CounterFieldsContext for CounterQuery');
    }
    return _builder(context);
  }
}

class CounterSelect extends SelectOptions<Counter, CounterPartial> {
  const CounterSelect({
    this.id = true,
    this.name = true,
    this.description = true,
    this.isActive = true,
    this.createdAt = true,
    this.updatedAt = true,
    this.storeId = true,
    this.relations,
  });

  final bool id;

  final bool name;

  final bool description;

  final bool isActive;

  final bool createdAt;

  final bool updatedAt;

  final bool storeId;

  final CounterRelations? relations;

  @override
  bool get hasSelections =>
      id ||
      name ||
      description ||
      isActive ||
      createdAt ||
      updatedAt ||
      storeId ||
      (relations?.hasSelections ?? false);

  @override
  SelectOptions<Counter, CounterPartial> withRelations(
    RelationsOptions<Counter, CounterPartial>? relations,
  ) {
    return CounterSelect(
      id: id,
      name: name,
      description: description,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      storeId: storeId,
      relations: relations as CounterRelations?,
    );
  }

  @override
  void collect(
    QueryFieldsContext<Counter> context,
    List<SelectField> out, {
    String? path,
  }) {
    if (context is! CounterFieldsContext) {
      throw ArgumentError('Expected CounterFieldsContext for CounterSelect');
    }
    final CounterFieldsContext scoped = context;
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
    final rels = relations;
    if (rels != null && rels.hasSelections) {
      rels.collect(scoped, out, path: path);
    }
  }

  @override
  CounterPartial hydrate(Map<String, dynamic> row, {String? path}) {
    StorePartial? storePartial;
    final storeSelect = relations?.store;
    if (storeSelect != null && storeSelect.hasSelections) {
      storePartial = storeSelect.hydrate(row, path: extendPath(path, 'store'));
    }
    return CounterPartial(
      id: id ? readValue(row, 'id', path: path) as String : null,
      name: name ? readValue(row, 'name', path: path) as String : null,
      description: description
          ? readValue(row, 'description', path: path) as String?
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
    );
  }

  @override
  bool get hasCollectionRelations => false;

  @override
  String? get primaryKeyColumn => 'id';
}

class CounterRelations extends RelationsOptions<Counter, CounterPartial> {
  const CounterRelations({this.store});

  final StoreSelect? store;

  @override
  bool get hasSelections => (store?.hasSelections ?? false);

  @override
  void collect(
    QueryFieldsContext<Counter> context,
    List<SelectField> out, {
    String? path,
  }) {
    if (context is! CounterFieldsContext) {
      throw ArgumentError('Expected CounterFieldsContext for CounterRelations');
    }
    final CounterFieldsContext scoped = context;

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

class CounterPartial extends PartialEntity<Counter> {
  const CounterPartial({
    this.id,
    this.name,
    this.description,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.storeId,
    this.store,
  });

  final String? id;

  final String? name;

  final String? description;

  final bool? isActive;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? storeId;

  final StorePartial? store;

  @override
  Object? get primaryKeyValue {
    return id;
  }

  @override
  CounterInsertDto toInsertDto() {
    final missing = <String>[];
    if (name == null) missing.add('name');
    if (isActive == null) missing.add('isActive');
    if (missing.isNotEmpty) {
      throw StateError(
        'Cannot convert CounterPartial to CounterInsertDto: missing required fields: ${missing.join(', ')}',
      );
    }
    return CounterInsertDto(
      name: name!,
      description: description,
      isActive: isActive!,
      createdAt: createdAt,
      updatedAt: updatedAt,
      storeId: storeId,
    );
  }

  @override
  CounterUpdateDto toUpdateDto() {
    return CounterUpdateDto(
      name: name,
      description: description,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      storeId: storeId,
    );
  }

  @override
  Counter toEntity() {
    final missing = <String>[];
    if (id == null) missing.add('id');
    if (name == null) missing.add('name');
    if (isActive == null) missing.add('isActive');
    if (missing.isNotEmpty) {
      throw StateError(
        'Cannot convert CounterPartial to Counter: missing required fields: ${missing.join(', ')}',
      );
    }
    return Counter(
      id: id!,
      name: name!,
      description: description,
      isActive: isActive!,
      createdAt: createdAt,
      updatedAt: updatedAt,
      store: store?.toEntity(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (isActive != null) 'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
      if (store != null) 'store': store?.toJson(),
      if (storeId != null) 'storeId': storeId,
    };
  }
}

class CounterInsertDto implements InsertDto<Counter> {
  const CounterInsertDto({
    required this.name,
    this.description,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.storeId,
  });

  final String name;

  final String? description;

  final bool isActive;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? storeId;

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'is_active': isActive,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      if (storeId != null) 'store_id': storeId,
    };
  }

  Map<String, dynamic> get cascades {
    return const {};
  }

  CounterInsertDto copyWith({
    String? name,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? storeId,
  }) {
    return CounterInsertDto(
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      storeId: storeId ?? this.storeId,
    );
  }
}

class CounterUpdateDto implements UpdateDto<Counter> {
  const CounterUpdateDto({
    this.name,
    this.description,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.storeId,
  });

  final String? name;

  final String? description;

  final bool? isActive;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? storeId;

  @override
  Map<String, dynamic> toMap() {
    return {
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null)
        'created_at': createdAt is DateTime
            ? (createdAt as DateTime).toIso8601String()
            : createdAt?.toString(),
      'updated_at': DateTime.now().toIso8601String(),
      if (storeId != null) 'store_id': storeId,
    };
  }

  Map<String, dynamic> get cascades {
    return const {};
  }
}

class CounterRepository extends EntityRepository<Counter, CounterPartial> {
  CounterRepository(EngineAdapter engine)
    : super(
        $CounterEntityDescriptor,
        engine,
        $CounterEntityDescriptor.fieldsContext,
      );
}

extension CounterJson on Counter {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
      if (store != null) 'store': store?.toJson(),
    };
  }
}

extension CounterCodec on Counter {
  Object? toEncodable() {
    return toJson();
  }

  String toJsonString() {
    return encodeJsonColumn(toJson()) as String;
  }
}

extension CounterPartialCodec on CounterPartial {
  Object? toEncodable() {
    return toJson();
  }

  String toJsonString() {
    return encodeJsonColumn(toJson()) as String;
  }
}

var $isCounterJsonCodecInitialized = false;
void $initCounterJsonCodec() {
  if ($isCounterJsonCodecInitialized) return;
  EntityJsonRegistry.register<Counter>((value) => CounterJson(value).toJson());
  $isCounterJsonCodecInitialized = true;
}

extension CounterRepositoryExtensions
    on EntityRepository<Counter, PartialEntity<Counter>> {}
