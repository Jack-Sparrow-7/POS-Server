// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'merchant.dart';

// **************************************************************************
// LoxiaEntityGenerator
// **************************************************************************

final EntityDescriptor<Merchant, MerchantPartial> $MerchantEntityDescriptor =
    () {
      $initMerchantJsonCodec();
      return EntityDescriptor(
        entityType: Merchant,
        tableName: 'merchants',
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
            name: 'business_name',
            propertyName: 'businessName',
            type: ColumnType.text,
            nullable: false,
            unique: false,
            isPrimaryKey: false,
            autoIncrement: false,
            uuid: false,
            isDeletedAt: false,
          ),
          ColumnDescriptor(
            name: 'mobile_number',
            propertyName: 'mobileNumber',
            type: ColumnType.text,
            nullable: false,
            unique: true,
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
            fieldName: 'stores',
            type: RelationType.oneToMany,
            target: Store,
            isOwningSide: false,
            mappedBy: 'merchant',
            fetch: RelationFetchStrategy.lazy,
            cascade: const [],
            cascadePersist: false,
            cascadeMerge: false,
            cascadeRemove: false,
          ),
        ],
        fromRow: (row) => Merchant(
          id: (row['id'] as String),
          name: (row['name'] as String),
          businessName: (row['business_name'] as String),
          mobileNumber: (row['mobile_number'] as String),
          email: (row['email'] as String),
          passwordHash: (row['password_hash'] as String),
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
          stores: const <Store>[],
        ),
        toRow: (e) => {
          'id': e.id,
          'name': e.name,
          'business_name': e.businessName,
          'mobile_number': e.mobileNumber,
          'email': e.email,
          'password_hash': e.passwordHash,
          'created_at': e.createdAt?.toIso8601String(),
          'updated_at': e.updatedAt?.toIso8601String(),
        },
        fieldsContext: const MerchantFieldsContext(),
        repositoryFactory: (EngineAdapter engine) => MerchantRepository(engine),
        hooks: EntityHooks<Merchant>(
          prePersist: (e) {
            e.createdAt = DateTime.now();
            e.updatedAt = DateTime.now();
          },
          preUpdate: (e) {
            e.updatedAt = DateTime.now();
          },
        ),
        defaultSelect: () => MerchantSelect(),
      );
    }();

class MerchantFieldsContext extends QueryFieldsContext<Merchant> {
  const MerchantFieldsContext([super.runtimeContext, super.alias]);

  @override
  MerchantFieldsContext bind(
    QueryRuntimeContext runtimeContext,
    String alias,
  ) => MerchantFieldsContext(runtimeContext, alias);

  QueryField<String> get id => field<String>('id');

  QueryField<String> get name => field<String>('name');

  QueryField<String> get businessName => field<String>('business_name');

  QueryField<String> get mobileNumber => field<String>('mobile_number');

  QueryField<String> get email => field<String>('email');

  QueryField<String> get passwordHash => field<String>('password_hash');

  QueryField<DateTime?> get createdAt => field<DateTime?>('created_at');

  QueryField<DateTime?> get updatedAt => field<DateTime?>('updated_at');

  /// Find the owning relation on the target entity to get join column info
  StoreFieldsContext get stores {
    final targetRelation = $StoreEntityDescriptor.relations.firstWhere(
      (r) => r.fieldName == 'merchant',
    );
    final joinColumn = targetRelation.joinColumn!;
    final alias = ensureRelationJoin(
      relationName: 'stores',
      targetTableName: $StoreEntityDescriptor.qualifiedTableName,
      localColumn: joinColumn.referencedColumnName,
      foreignColumn: joinColumn.name,
      joinType: JoinType.left,
    );
    return StoreFieldsContext(runtimeOrThrow, alias);
  }
}

class MerchantQuery extends QueryBuilder<Merchant> {
  const MerchantQuery(this._builder);

  final WhereExpression Function(MerchantFieldsContext) _builder;

  @override
  WhereExpression build(QueryFieldsContext<Merchant> context) {
    if (context is! MerchantFieldsContext) {
      throw ArgumentError('Expected MerchantFieldsContext for MerchantQuery');
    }
    return _builder(context);
  }
}

class MerchantSelect extends SelectOptions<Merchant, MerchantPartial> {
  const MerchantSelect({
    this.id = true,
    this.name = true,
    this.businessName = true,
    this.mobileNumber = true,
    this.email = true,
    this.passwordHash = true,
    this.createdAt = true,
    this.updatedAt = true,
    this.relations,
  });

  final bool id;

  final bool name;

  final bool businessName;

  final bool mobileNumber;

  final bool email;

  final bool passwordHash;

  final bool createdAt;

  final bool updatedAt;

  final MerchantRelations? relations;

  @override
  bool get hasSelections =>
      id ||
      name ||
      businessName ||
      mobileNumber ||
      email ||
      passwordHash ||
      createdAt ||
      updatedAt ||
      (relations?.hasSelections ?? false);

  @override
  SelectOptions<Merchant, MerchantPartial> withRelations(
    RelationsOptions<Merchant, MerchantPartial>? relations,
  ) {
    return MerchantSelect(
      id: id,
      name: name,
      businessName: businessName,
      mobileNumber: mobileNumber,
      email: email,
      passwordHash: passwordHash,
      createdAt: createdAt,
      updatedAt: updatedAt,
      relations: relations as MerchantRelations?,
    );
  }

  @override
  void collect(
    QueryFieldsContext<Merchant> context,
    List<SelectField> out, {
    String? path,
  }) {
    if (context is! MerchantFieldsContext) {
      throw ArgumentError('Expected MerchantFieldsContext for MerchantSelect');
    }
    final MerchantFieldsContext scoped = context;
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
    if (businessName) {
      out.add(
        SelectField(
          'business_name',
          tableAlias: tableAlias,
          alias: aliasFor('business_name'),
        ),
      );
    }
    if (mobileNumber) {
      out.add(
        SelectField(
          'mobile_number',
          tableAlias: tableAlias,
          alias: aliasFor('mobile_number'),
        ),
      );
    }
    if (email) {
      out.add(
        SelectField('email', tableAlias: tableAlias, alias: aliasFor('email')),
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
    final rels = relations;
    if (rels != null && rels.hasSelections) {
      rels.collect(scoped, out, path: path);
    }
  }

  @override
  MerchantPartial hydrate(Map<String, dynamic> row, {String? path}) {
    // Collection relation stores requires row aggregation
    return MerchantPartial(
      id: id ? readValue(row, 'id', path: path) as String : null,
      name: name ? readValue(row, 'name', path: path) as String : null,
      businessName: businessName
          ? readValue(row, 'business_name', path: path) as String
          : null,
      mobileNumber: mobileNumber
          ? readValue(row, 'mobile_number', path: path) as String
          : null,
      email: email ? readValue(row, 'email', path: path) as String : null,
      passwordHash: passwordHash
          ? readValue(row, 'password_hash', path: path) as String
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
      stores: null,
    );
  }

  @override
  bool get hasCollectionRelations => true;

  @override
  String? get primaryKeyColumn => 'id';

  @override
  List<MerchantPartial> aggregateRows(
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
      // Aggregate stores collection
      final storesSelect = relations?.stores;
      List<StorePartial>? storesList;
      if (storesSelect != null && storesSelect.hasSelections) {
        final relationPath = extendPath(path, 'stores');
        storesList = <StorePartial>[];
        final seenKeys = <Object?>{};
        for (final row in groupRows) {
          final itemKey = storesSelect.readValue(
            row,
            storesSelect.primaryKeyColumn ?? 'id',
            path: relationPath,
          );
          if (itemKey != null && seenKeys.add(itemKey)) {
            storesList.add(storesSelect.hydrate(row, path: relationPath));
          }
        }
      }
      return MerchantPartial(
        id: base.id,
        name: base.name,
        businessName: base.businessName,
        mobileNumber: base.mobileNumber,
        email: base.email,
        passwordHash: base.passwordHash,
        createdAt: base.createdAt,
        updatedAt: base.updatedAt,
        stores: storesList,
      );
    }).toList();
  }
}

class MerchantRelations extends RelationsOptions<Merchant, MerchantPartial> {
  const MerchantRelations({this.stores});

  final StoreSelect? stores;

  @override
  bool get hasSelections => (stores?.hasSelections ?? false);

  @override
  void collect(
    QueryFieldsContext<Merchant> context,
    List<SelectField> out, {
    String? path,
  }) {
    if (context is! MerchantFieldsContext) {
      throw ArgumentError(
        'Expected MerchantFieldsContext for MerchantRelations',
      );
    }
    final MerchantFieldsContext scoped = context;

    final storesSelect = stores;
    if (storesSelect != null && storesSelect.hasSelections) {
      final relationPath = path == null || path.isEmpty
          ? 'stores'
          : '${path}_stores';
      final relationContext = scoped.stores;
      storesSelect.collect(relationContext, out, path: relationPath);
    }
  }
}

class MerchantPartial extends PartialEntity<Merchant> {
  const MerchantPartial({
    this.id,
    this.name,
    this.businessName,
    this.mobileNumber,
    this.email,
    this.passwordHash,
    this.createdAt,
    this.updatedAt,
    this.stores,
  });

  final String? id;

  final String? name;

  final String? businessName;

  final String? mobileNumber;

  final String? email;

  final String? passwordHash;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final List<StorePartial>? stores;

  @override
  Object? get primaryKeyValue {
    return id;
  }

  @override
  MerchantInsertDto toInsertDto() {
    final missing = <String>[];
    if (name == null) missing.add('name');
    if (businessName == null) missing.add('businessName');
    if (mobileNumber == null) missing.add('mobileNumber');
    if (email == null) missing.add('email');
    if (passwordHash == null) missing.add('passwordHash');
    if (missing.isNotEmpty) {
      throw StateError(
        'Cannot convert MerchantPartial to MerchantInsertDto: missing required fields: ${missing.join(', ')}',
      );
    }
    return MerchantInsertDto(
      name: name!,
      businessName: businessName!,
      mobileNumber: mobileNumber!,
      email: email!,
      passwordHash: passwordHash!,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  MerchantUpdateDto toUpdateDto() {
    return MerchantUpdateDto(
      name: name,
      businessName: businessName,
      mobileNumber: mobileNumber,
      email: email,
      passwordHash: passwordHash,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  Merchant toEntity() {
    final missing = <String>[];
    if (id == null) missing.add('id');
    if (name == null) missing.add('name');
    if (businessName == null) missing.add('businessName');
    if (mobileNumber == null) missing.add('mobileNumber');
    if (email == null) missing.add('email');
    if (passwordHash == null) missing.add('passwordHash');
    if (missing.isNotEmpty) {
      throw StateError(
        'Cannot convert MerchantPartial to Merchant: missing required fields: ${missing.join(', ')}',
      );
    }
    return Merchant(
      id: id!,
      name: name!,
      businessName: businessName!,
      mobileNumber: mobileNumber!,
      email: email!,
      passwordHash: passwordHash!,
      createdAt: createdAt,
      updatedAt: updatedAt,
      stores: stores?.map((p) => p.toEntity()).toList() ?? const <Store>[],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (businessName != null) 'businessName': businessName,
      if (mobileNumber != null) 'mobileNumber': mobileNumber,
      if (email != null) 'email': email,
      if (passwordHash != null) 'passwordHash': passwordHash,
      if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
      if (stores != null) 'stores': stores?.map((e) => e.toJson()).toList(),
    };
  }
}

class MerchantInsertDto implements InsertDto<Merchant> {
  const MerchantInsertDto({
    required this.name,
    required this.businessName,
    required this.mobileNumber,
    required this.email,
    required this.passwordHash,
    this.createdAt,
    this.updatedAt,
  });

  final String name;

  final String businessName;

  final String mobileNumber;

  final String email;

  final String passwordHash;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'business_name': businessName,
      'mobile_number': mobileNumber,
      'email': email,
      'password_hash': passwordHash,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> get cascades {
    return const {};
  }

  MerchantInsertDto copyWith({
    String? name,
    String? businessName,
    String? mobileNumber,
    String? email,
    String? passwordHash,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MerchantInsertDto(
      name: name ?? this.name,
      businessName: businessName ?? this.businessName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class MerchantUpdateDto implements UpdateDto<Merchant> {
  const MerchantUpdateDto({
    this.name,
    this.businessName,
    this.mobileNumber,
    this.email,
    this.passwordHash,
    this.createdAt,
    this.updatedAt,
  });

  final String? name;

  final String? businessName;

  final String? mobileNumber;

  final String? email;

  final String? passwordHash;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  @override
  Map<String, dynamic> toMap() {
    return {
      if (name != null) 'name': name,
      if (businessName != null) 'business_name': businessName,
      if (mobileNumber != null) 'mobile_number': mobileNumber,
      if (email != null) 'email': email,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (createdAt != null)
        'created_at': createdAt is DateTime
            ? (createdAt as DateTime).toIso8601String()
            : createdAt?.toString(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> get cascades {
    return const {};
  }
}

class MerchantRepository extends EntityRepository<Merchant, MerchantPartial> {
  MerchantRepository(EngineAdapter engine)
    : super(
        $MerchantEntityDescriptor,
        engine,
        $MerchantEntityDescriptor.fieldsContext,
      );
}

extension MerchantJson on Merchant {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'businessName': businessName,
      'mobileNumber': mobileNumber,
      'email': email,
      'passwordHash': passwordHash,
      if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
      if (stores != null) 'stores': stores?.map((e) => e.toJson()).toList(),
    };
  }
}

extension MerchantCodec on Merchant {
  Object? toEncodable() {
    return toJson();
  }

  String toJsonString() {
    return encodeJsonColumn(toJson()) as String;
  }
}

extension MerchantPartialCodec on MerchantPartial {
  Object? toEncodable() {
    return toJson();
  }

  String toJsonString() {
    return encodeJsonColumn(toJson()) as String;
  }
}

var $isMerchantJsonCodecInitialized = false;
void $initMerchantJsonCodec() {
  if ($isMerchantJsonCodecInitialized) return;
  EntityJsonRegistry.register<Merchant>(
    (value) => MerchantJson(value).toJson(),
  );
  $isMerchantJsonCodecInitialized = true;
}

extension MerchantRepositoryExtensions
    on EntityRepository<Merchant, PartialEntity<Merchant>> {}
