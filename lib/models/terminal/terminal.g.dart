// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'terminal.dart';

// **************************************************************************
// LoxiaEntityGenerator
// **************************************************************************

final EntityDescriptor<Terminal, TerminalPartial> $TerminalEntityDescriptor =
    () {
      $initTerminalJsonCodec();
      return EntityDescriptor(
        entityType: Terminal,
        tableName: 'terminals',
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
            name: 'terminal_code',
            propertyName: 'terminalCode',
            type: ColumnType.text,
            nullable: false,
            unique: true,
            isPrimaryKey: false,
            autoIncrement: false,
            uuid: false,
            isDeletedAt: false,
          ),
          ColumnDescriptor(
            name: 'password_hash',
            propertyName: 'passwordHash',
            type: ColumnType.text,
            nullable: false,
            unique: false,
            isPrimaryKey: false,
            autoIncrement: false,
            uuid: false,
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
            name: 'token_version',
            propertyName: 'tokenVersion',
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
        fromRow: (row) => Terminal(
          id: (row['id'] as String),
          terminalCode: (row['terminal_code'] as String),
          passwordHash: (row['password_hash'] as String),
          name: (row['name'] as String),
          isActive: row['is_active'] is bool
              ? row['is_active']
              : row['is_active'] == 1,
          tokenVersion: (row['token_version'] as int),
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
          'terminal_code': e.terminalCode,
          'password_hash': e.passwordHash,
          'name': e.name,
          'is_active': e.isActive,
          'token_version': e.tokenVersion,
          'created_at': e.createdAt?.toIso8601String(),
          'updated_at': e.updatedAt?.toIso8601String(),
          'deleted_at': e.deletedAt?.toIso8601String(),
          'store_id': e.store?.id,
        },
        fieldsContext: const TerminalFieldsContext(),
        repositoryFactory: (EngineAdapter engine) => TerminalRepository(engine),
        hooks: EntityHooks<Terminal>(
          prePersist: (e) {
            e.createdAt = DateTime.now();
            e.updatedAt = DateTime.now();
          },
          preUpdate: (e) {
            e.updatedAt = DateTime.now();
          },
        ),
        defaultSelect: () => TerminalSelect(),
      );
    }();

class TerminalFieldsContext extends QueryFieldsContext<Terminal> {
  const TerminalFieldsContext([super.runtimeContext, super.alias]);

  @override
  TerminalFieldsContext bind(
    QueryRuntimeContext runtimeContext,
    String alias,
  ) => TerminalFieldsContext(runtimeContext, alias);

  QueryField<String> get id => field<String>('id');

  QueryField<String> get terminalCode => field<String>('terminal_code');

  QueryField<String> get passwordHash => field<String>('password_hash');

  QueryField<String> get name => field<String>('name');

  QueryField<bool> get isActive => field<bool>('is_active');

  QueryField<int> get tokenVersion => field<int>('token_version');

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

class TerminalQuery extends QueryBuilder<Terminal> {
  const TerminalQuery(this._builder);

  final WhereExpression Function(TerminalFieldsContext) _builder;

  @override
  WhereExpression build(QueryFieldsContext<Terminal> context) {
    if (context is! TerminalFieldsContext) {
      throw ArgumentError('Expected TerminalFieldsContext for TerminalQuery');
    }
    return _builder(context);
  }
}

class TerminalSelect extends SelectOptions<Terminal, TerminalPartial> {
  const TerminalSelect({
    this.id = true,
    this.terminalCode = true,
    this.passwordHash = true,
    this.name = true,
    this.isActive = true,
    this.tokenVersion = true,
    this.createdAt = true,
    this.updatedAt = true,
    this.deletedAt = true,
    this.storeId = true,
    this.relations,
  });

  final bool id;

  final bool terminalCode;

  final bool passwordHash;

  final bool name;

  final bool isActive;

  final bool tokenVersion;

  final bool createdAt;

  final bool updatedAt;

  final bool deletedAt;

  final bool storeId;

  final TerminalRelations? relations;

  @override
  bool get hasSelections =>
      id ||
      terminalCode ||
      passwordHash ||
      name ||
      isActive ||
      tokenVersion ||
      createdAt ||
      updatedAt ||
      deletedAt ||
      storeId ||
      (relations?.hasSelections ?? false);

  @override
  SelectOptions<Terminal, TerminalPartial> withRelations(
    RelationsOptions<Terminal, TerminalPartial>? relations,
  ) {
    return TerminalSelect(
      id: id,
      terminalCode: terminalCode,
      passwordHash: passwordHash,
      name: name,
      isActive: isActive,
      tokenVersion: tokenVersion,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      storeId: storeId,
      relations: relations as TerminalRelations?,
    );
  }

  @override
  void collect(
    QueryFieldsContext<Terminal> context,
    List<SelectField> out, {
    String? path,
  }) {
    if (context is! TerminalFieldsContext) {
      throw ArgumentError('Expected TerminalFieldsContext for TerminalSelect');
    }
    final TerminalFieldsContext scoped = context;
    String? aliasFor(String column) {
      final current = path;
      if (current == null || current.isEmpty) return null;
      return '${current}_$column';
    }

    final tableAlias = scoped.currentAlias;
    if (id) {
      out.add(SelectField('id', tableAlias: tableAlias, alias: aliasFor('id')));
    }
    if (terminalCode) {
      out.add(
        SelectField(
          'terminal_code',
          tableAlias: tableAlias,
          alias: aliasFor('terminal_code'),
        ),
      );
    }
    if (passwordHash) {
      out.add(
        SelectField(
          'password_hash',
          tableAlias: tableAlias,
          alias: aliasFor('password_hash'),
        ),
      );
    }
    if (name) {
      out.add(
        SelectField('name', tableAlias: tableAlias, alias: aliasFor('name')),
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
    if (tokenVersion) {
      out.add(
        SelectField(
          'token_version',
          tableAlias: tableAlias,
          alias: aliasFor('token_version'),
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
  TerminalPartial hydrate(Map<String, dynamic> row, {String? path}) {
    StorePartial? storePartial;
    final storeSelect = relations?.store;
    if (storeSelect != null && storeSelect.hasSelections) {
      storePartial = storeSelect.hydrate(row, path: extendPath(path, 'store'));
    }
    return TerminalPartial(
      id: id ? readValue(row, 'id', path: path) as String : null,
      terminalCode: terminalCode
          ? readValue(row, 'terminal_code', path: path) as String
          : null,
      passwordHash: passwordHash
          ? readValue(row, 'password_hash', path: path) as String
          : null,
      name: name ? readValue(row, 'name', path: path) as String : null,
      isActive: isActive
          ? readValue(row, 'is_active', path: path) as bool
          : null,
      tokenVersion: tokenVersion
          ? readValue(row, 'token_version', path: path) as int
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

class TerminalRelations extends RelationsOptions<Terminal, TerminalPartial> {
  const TerminalRelations({this.store});

  final StoreSelect? store;

  @override
  bool get hasSelections => (store?.hasSelections ?? false);

  @override
  void collect(
    QueryFieldsContext<Terminal> context,
    List<SelectField> out, {
    String? path,
  }) {
    if (context is! TerminalFieldsContext) {
      throw ArgumentError(
        'Expected TerminalFieldsContext for TerminalRelations',
      );
    }
    final TerminalFieldsContext scoped = context;

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

class TerminalPartial extends PartialEntity<Terminal> {
  const TerminalPartial({
    this.id,
    this.terminalCode,
    this.passwordHash,
    this.name,
    this.isActive,
    this.tokenVersion,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.storeId,
    this.store,
  });

  final String? id;

  final String? terminalCode;

  final String? passwordHash;

  final String? name;

  final bool? isActive;

  final int? tokenVersion;

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
  TerminalInsertDto toInsertDto() {
    final missing = <String>[];
    if (terminalCode == null) missing.add('terminalCode');
    if (passwordHash == null) missing.add('passwordHash');
    if (name == null) missing.add('name');
    if (isActive == null) missing.add('isActive');
    if (tokenVersion == null) missing.add('tokenVersion');
    if (missing.isNotEmpty) {
      throw StateError(
        'Cannot convert TerminalPartial to TerminalInsertDto: missing required fields: ${missing.join(', ')}',
      );
    }
    return TerminalInsertDto(
      terminalCode: terminalCode!,
      passwordHash: passwordHash!,
      name: name!,
      isActive: isActive!,
      tokenVersion: tokenVersion!,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      storeId: storeId,
    );
  }

  @override
  TerminalUpdateDto toUpdateDto() {
    return TerminalUpdateDto(
      terminalCode: terminalCode,
      passwordHash: passwordHash,
      name: name,
      isActive: isActive,
      tokenVersion: tokenVersion,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      storeId: storeId,
    );
  }

  @override
  Terminal toEntity() {
    final missing = <String>[];
    if (id == null) missing.add('id');
    if (terminalCode == null) missing.add('terminalCode');
    if (passwordHash == null) missing.add('passwordHash');
    if (name == null) missing.add('name');
    if (isActive == null) missing.add('isActive');
    if (tokenVersion == null) missing.add('tokenVersion');
    if (missing.isNotEmpty) {
      throw StateError(
        'Cannot convert TerminalPartial to Terminal: missing required fields: ${missing.join(', ')}',
      );
    }
    return Terminal(
      id: id!,
      terminalCode: terminalCode!,
      passwordHash: passwordHash!,
      name: name!,
      isActive: isActive!,
      tokenVersion: tokenVersion!,
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
      if (terminalCode != null) 'terminalCode': terminalCode,
      if (passwordHash != null) 'passwordHash': passwordHash,
      if (name != null) 'name': name,
      if (isActive != null) 'isActive': isActive,
      if (tokenVersion != null) 'tokenVersion': tokenVersion,
      if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
      if (deletedAt != null) 'deletedAt': deletedAt?.toIso8601String(),
      if (store != null) 'store': store?.toJson(),
      if (storeId != null) 'storeId': storeId,
    };
  }
}

class TerminalInsertDto implements InsertDto<Terminal> {
  const TerminalInsertDto({
    required this.terminalCode,
    required this.passwordHash,
    required this.name,
    required this.isActive,
    required this.tokenVersion,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.storeId,
  });

  final String terminalCode;

  final String passwordHash;

  final String name;

  final bool isActive;

  final int tokenVersion;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final DateTime? deletedAt;

  final String? storeId;

  @override
  Map<String, dynamic> toMap() {
    return {
      'terminal_code': terminalCode,
      'password_hash': passwordHash,
      'name': name,
      'is_active': isActive,
      'token_version': tokenVersion,
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

  TerminalInsertDto copyWith({
    String? terminalCode,
    String? passwordHash,
    String? name,
    bool? isActive,
    int? tokenVersion,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? storeId,
  }) {
    return TerminalInsertDto(
      terminalCode: terminalCode ?? this.terminalCode,
      passwordHash: passwordHash ?? this.passwordHash,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      tokenVersion: tokenVersion ?? this.tokenVersion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      storeId: storeId ?? this.storeId,
    );
  }
}

class TerminalUpdateDto implements UpdateDto<Terminal> {
  const TerminalUpdateDto({
    this.terminalCode,
    this.passwordHash,
    this.name,
    this.isActive,
    this.tokenVersion,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.storeId,
  });

  final String? terminalCode;

  final String? passwordHash;

  final String? name;

  final bool? isActive;

  final int? tokenVersion;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final DateTime? deletedAt;

  final String? storeId;

  @override
  Map<String, dynamic> toMap() {
    return {
      if (terminalCode != null) 'terminal_code': terminalCode,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (name != null) 'name': name,
      if (isActive != null) 'is_active': isActive,
      if (tokenVersion != null) 'token_version': tokenVersion,
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

class TerminalRepository extends EntityRepository<Terminal, TerminalPartial> {
  TerminalRepository(EngineAdapter engine)
    : super(
        $TerminalEntityDescriptor,
        engine,
        $TerminalEntityDescriptor.fieldsContext,
      );
}

extension TerminalJson on Terminal {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'terminalCode': terminalCode,
      'passwordHash': passwordHash,
      'name': name,
      'isActive': isActive,
      'tokenVersion': tokenVersion,
      if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
      if (deletedAt != null) 'deletedAt': deletedAt?.toIso8601String(),
      if (store != null) 'store': store?.toJson(),
    };
  }
}

extension TerminalCodec on Terminal {
  Object? toEncodable() {
    return toJson();
  }

  String toJsonString() {
    return encodeJsonColumn(toJson()) as String;
  }
}

extension TerminalPartialCodec on TerminalPartial {
  Object? toEncodable() {
    return toJson();
  }

  String toJsonString() {
    return encodeJsonColumn(toJson()) as String;
  }
}

var $isTerminalJsonCodecInitialized = false;
void $initTerminalJsonCodec() {
  if ($isTerminalJsonCodecInitialized) return;
  EntityJsonRegistry.register<Terminal>(
    (value) => TerminalJson(value).toJson(),
  );
  $isTerminalJsonCodecInitialized = true;
}

extension TerminalRepositoryExtensions
    on EntityRepository<Terminal, PartialEntity<Terminal>> {}
