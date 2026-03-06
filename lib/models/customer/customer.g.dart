// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer.dart';

// **************************************************************************
// LoxiaEntityGenerator
// **************************************************************************

final EntityDescriptor<Customer, CustomerPartial> $CustomerEntityDescriptor =
    () {
      $initCustomerJsonCodec();
      return EntityDescriptor(
        entityType: Customer,
        tableName: 'customers',
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
        relations: const [],
        fromRow: (row) => Customer(
          id: (row['id'] as String),
          name: (row['name'] as String),
          mobileNumber: (row['mobile_number'] as String),
          email: (row['email'] as String),
          passwordHash: (row['password_hash'] as String),
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
        ),
        toRow: (e) => {
          'id': e.id,
          'name': e.name,
          'mobile_number': e.mobileNumber,
          'email': e.email,
          'password_hash': e.passwordHash,
          'is_active': e.isActive,
          'token_version': e.tokenVersion,
          'created_at': e.createdAt?.toIso8601String(),
          'updated_at': e.updatedAt?.toIso8601String(),
          'deleted_at': e.deletedAt?.toIso8601String(),
        },
        fieldsContext: const CustomerFieldsContext(),
        repositoryFactory: (EngineAdapter engine) => CustomerRepository(engine),
        hooks: EntityHooks<Customer>(
          prePersist: (e) {
            e.createdAt = DateTime.now();
            e.updatedAt = DateTime.now();
          },
          preUpdate: (e) {
            e.updatedAt = DateTime.now();
          },
        ),
        defaultSelect: () => CustomerSelect(),
      );
    }();

class CustomerFieldsContext extends QueryFieldsContext<Customer> {
  const CustomerFieldsContext([super.runtimeContext, super.alias]);

  @override
  CustomerFieldsContext bind(
    QueryRuntimeContext runtimeContext,
    String alias,
  ) => CustomerFieldsContext(runtimeContext, alias);

  QueryField<String> get id => field<String>('id');

  QueryField<String> get name => field<String>('name');

  QueryField<String> get mobileNumber => field<String>('mobile_number');

  QueryField<String> get email => field<String>('email');

  QueryField<String> get passwordHash => field<String>('password_hash');

  QueryField<bool> get isActive => field<bool>('is_active');

  QueryField<int> get tokenVersion => field<int>('token_version');

  QueryField<DateTime?> get createdAt => field<DateTime?>('created_at');

  QueryField<DateTime?> get updatedAt => field<DateTime?>('updated_at');

  QueryField<DateTime?> get deletedAt => field<DateTime?>('deleted_at');
}

class CustomerQuery extends QueryBuilder<Customer> {
  const CustomerQuery(this._builder);

  final WhereExpression Function(CustomerFieldsContext) _builder;

  @override
  WhereExpression build(QueryFieldsContext<Customer> context) {
    if (context is! CustomerFieldsContext) {
      throw ArgumentError('Expected CustomerFieldsContext for CustomerQuery');
    }
    return _builder(context);
  }
}

class CustomerSelect extends SelectOptions<Customer, CustomerPartial> {
  const CustomerSelect({
    this.id = true,
    this.name = true,
    this.mobileNumber = true,
    this.email = true,
    this.passwordHash = true,
    this.isActive = true,
    this.tokenVersion = true,
    this.createdAt = true,
    this.updatedAt = true,
    this.deletedAt = true,
    this.relations,
  });

  final bool id;

  final bool name;

  final bool mobileNumber;

  final bool email;

  final bool passwordHash;

  final bool isActive;

  final bool tokenVersion;

  final bool createdAt;

  final bool updatedAt;

  final bool deletedAt;

  final CustomerRelations? relations;

  @override
  bool get hasSelections =>
      id ||
      name ||
      mobileNumber ||
      email ||
      passwordHash ||
      isActive ||
      tokenVersion ||
      createdAt ||
      updatedAt ||
      deletedAt ||
      (relations?.hasSelections ?? false);

  @override
  SelectOptions<Customer, CustomerPartial> withRelations(
    RelationsOptions<Customer, CustomerPartial>? relations,
  ) {
    return CustomerSelect(
      id: id,
      name: name,
      mobileNumber: mobileNumber,
      email: email,
      passwordHash: passwordHash,
      isActive: isActive,
      tokenVersion: tokenVersion,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      relations: relations as CustomerRelations?,
    );
  }

  @override
  void collect(
    QueryFieldsContext<Customer> context,
    List<SelectField> out, {
    String? path,
  }) {
    if (context is! CustomerFieldsContext) {
      throw ArgumentError('Expected CustomerFieldsContext for CustomerSelect');
    }
    final CustomerFieldsContext scoped = context;
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
    final rels = relations;
    if (rels != null && rels.hasSelections) {
      rels.collect(scoped, out, path: path);
    }
  }

  @override
  CustomerPartial hydrate(Map<String, dynamic> row, {String? path}) {
    return CustomerPartial(
      id: id ? readValue(row, 'id', path: path) as String : null,
      name: name ? readValue(row, 'name', path: path) as String : null,
      mobileNumber: mobileNumber
          ? readValue(row, 'mobile_number', path: path) as String
          : null,
      email: email ? readValue(row, 'email', path: path) as String : null,
      passwordHash: passwordHash
          ? readValue(row, 'password_hash', path: path) as String
          : null,
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
    );
  }

  @override
  bool get hasCollectionRelations => false;

  @override
  String? get primaryKeyColumn => 'id';
}

class CustomerRelations extends RelationsOptions<Customer, CustomerPartial> {
  const CustomerRelations();

  @override
  bool get hasSelections => false;

  @override
  void collect(
    QueryFieldsContext<Customer> context,
    List<SelectField> out, {
    String? path,
  }) {
    if (context is! CustomerFieldsContext) {
      throw ArgumentError(
        'Expected CustomerFieldsContext for CustomerRelations',
      );
    }
  }
}

class CustomerPartial extends PartialEntity<Customer> {
  const CustomerPartial({
    this.id,
    this.name,
    this.mobileNumber,
    this.email,
    this.passwordHash,
    this.isActive,
    this.tokenVersion,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  final String? id;

  final String? name;

  final String? mobileNumber;

  final String? email;

  final String? passwordHash;

  final bool? isActive;

  final int? tokenVersion;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final DateTime? deletedAt;

  @override
  Object? get primaryKeyValue {
    return id;
  }

  @override
  CustomerInsertDto toInsertDto() {
    final missing = <String>[];
    if (name == null) missing.add('name');
    if (mobileNumber == null) missing.add('mobileNumber');
    if (email == null) missing.add('email');
    if (passwordHash == null) missing.add('passwordHash');
    if (isActive == null) missing.add('isActive');
    if (tokenVersion == null) missing.add('tokenVersion');
    if (missing.isNotEmpty) {
      throw StateError(
        'Cannot convert CustomerPartial to CustomerInsertDto: missing required fields: ${missing.join(', ')}',
      );
    }
    return CustomerInsertDto(
      name: name!,
      mobileNumber: mobileNumber!,
      email: email!,
      passwordHash: passwordHash!,
      isActive: isActive!,
      tokenVersion: tokenVersion!,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }

  @override
  CustomerUpdateDto toUpdateDto() {
    return CustomerUpdateDto(
      name: name,
      mobileNumber: mobileNumber,
      email: email,
      passwordHash: passwordHash,
      isActive: isActive,
      tokenVersion: tokenVersion,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }

  @override
  Customer toEntity() {
    final missing = <String>[];
    if (id == null) missing.add('id');
    if (name == null) missing.add('name');
    if (mobileNumber == null) missing.add('mobileNumber');
    if (email == null) missing.add('email');
    if (passwordHash == null) missing.add('passwordHash');
    if (isActive == null) missing.add('isActive');
    if (tokenVersion == null) missing.add('tokenVersion');
    if (missing.isNotEmpty) {
      throw StateError(
        'Cannot convert CustomerPartial to Customer: missing required fields: ${missing.join(', ')}',
      );
    }
    return Customer(
      id: id!,
      name: name!,
      mobileNumber: mobileNumber!,
      email: email!,
      passwordHash: passwordHash!,
      isActive: isActive!,
      tokenVersion: tokenVersion!,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (mobileNumber != null) 'mobileNumber': mobileNumber,
      if (email != null) 'email': email,
      if (passwordHash != null) 'passwordHash': passwordHash,
      if (isActive != null) 'isActive': isActive,
      if (tokenVersion != null) 'tokenVersion': tokenVersion,
      if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
      if (deletedAt != null) 'deletedAt': deletedAt?.toIso8601String(),
    };
  }
}

class CustomerInsertDto implements InsertDto<Customer> {
  const CustomerInsertDto({
    required this.name,
    required this.mobileNumber,
    required this.email,
    required this.passwordHash,
    required this.isActive,
    required this.tokenVersion,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  final String name;

  final String mobileNumber;

  final String email;

  final String passwordHash;

  final bool isActive;

  final int tokenVersion;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final DateTime? deletedAt;

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'mobile_number': mobileNumber,
      'email': email,
      'password_hash': passwordHash,
      'is_active': isActive,
      'token_version': tokenVersion,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'deleted_at': deletedAt is DateTime
          ? (deletedAt as DateTime).toIso8601String()
          : deletedAt?.toString(),
    };
  }

  Map<String, dynamic> get cascades {
    return const {};
  }

  CustomerInsertDto copyWith({
    String? name,
    String? mobileNumber,
    String? email,
    String? passwordHash,
    bool? isActive,
    int? tokenVersion,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return CustomerInsertDto(
      name: name ?? this.name,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      isActive: isActive ?? this.isActive,
      tokenVersion: tokenVersion ?? this.tokenVersion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

class CustomerUpdateDto implements UpdateDto<Customer> {
  const CustomerUpdateDto({
    this.name,
    this.mobileNumber,
    this.email,
    this.passwordHash,
    this.isActive,
    this.tokenVersion,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  final String? name;

  final String? mobileNumber;

  final String? email;

  final String? passwordHash;

  final bool? isActive;

  final int? tokenVersion;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final DateTime? deletedAt;

  @override
  Map<String, dynamic> toMap() {
    return {
      if (name != null) 'name': name,
      if (mobileNumber != null) 'mobile_number': mobileNumber,
      if (email != null) 'email': email,
      if (passwordHash != null) 'password_hash': passwordHash,
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
    };
  }

  Map<String, dynamic> get cascades {
    return const {};
  }
}

class CustomerRepository extends EntityRepository<Customer, CustomerPartial> {
  CustomerRepository(EngineAdapter engine)
    : super(
        $CustomerEntityDescriptor,
        engine,
        $CustomerEntityDescriptor.fieldsContext,
      );
}

extension CustomerJson on Customer {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobileNumber': mobileNumber,
      'email': email,
      'passwordHash': passwordHash,
      'isActive': isActive,
      'tokenVersion': tokenVersion,
      if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
      if (deletedAt != null) 'deletedAt': deletedAt?.toIso8601String(),
    };
  }
}

extension CustomerCodec on Customer {
  Object? toEncodable() {
    return toJson();
  }

  String toJsonString() {
    return encodeJsonColumn(toJson()) as String;
  }
}

extension CustomerPartialCodec on CustomerPartial {
  Object? toEncodable() {
    return toJson();
  }

  String toJsonString() {
    return encodeJsonColumn(toJson()) as String;
  }
}

var $isCustomerJsonCodecInitialized = false;
void $initCustomerJsonCodec() {
  if ($isCustomerJsonCodecInitialized) return;
  EntityJsonRegistry.register<Customer>(
    (value) => CustomerJson(value).toJson(),
  );
  $isCustomerJsonCodecInitialized = true;
}

extension CustomerRepositoryExtensions
    on EntityRepository<Customer, PartialEntity<Customer>> {}
