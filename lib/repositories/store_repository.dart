import 'package:pos_server/models/store.dart';
import 'package:postgres/postgres.dart';

/// This file is responsible for handling all interactions with the store data.
class StoreRepository {
  /// Creates a new instance of [StoreRepository]
  /// with the given PostgreSQL connection pool.
  StoreRepository({required Pool<String> pool}) : _pool = pool;

  final Pool<String> _pool;

  /// Returns all stores for platform admin, including tenant name.
  Future<List<Store>> fetchAllForAdmin() async {
    final result = await _pool.execute(
      Sql.named('''
        SELECT s.id,
               s.tenant_id,
               s.name,
               s.slug,
               s.description,
               s.address,
               s.city,
               s.state,
               s.pincode,
               s.phone,
               s.gstin,
               s.subscription_status,
               s.subscription_started_at,
               s.subscription_expires_at,
               s.trial_expires_at,
               s.phonepe_client_id,
               s.phonepe_client_version,
               s.phonepe_client_secret,
               s.phonepe_configured,
               s.gst_enabled,
               s.is_open,
               s.is_active,
               s.created_at,
               s.updated_at,
               t.name AS tenant_name
        FROM stores s
        INNER JOIN tenants t ON t.id = s.tenant_id
        ORDER BY s.created_at DESC
      '''),
    );

    return result.map((row) => Store.fromRow(row.toColumnMap())).toList();
  }

  /// Returns all stores for a specific tenant.
  Future<List<Store>> fetchAllForTenant(String tenantId) async {
    final result = await _pool.execute(
      Sql.named('''
        SELECT s.id,
               s.tenant_id,
               s.name,
               s.slug,
               s.description,
               s.address,
               s.city,
               s.state,
               s.pincode,
               s.phone,
               s.gstin,
               s.subscription_status,
               s.subscription_started_at,
               s.subscription_expires_at,
               s.trial_expires_at,
               s.phonepe_client_id,
               s.phonepe_client_version,
               s.phonepe_client_secret,
               s.phonepe_configured,
               s.gst_enabled,
               s.is_open,
               s.is_active,
               s.created_at,
               s.updated_at,
               t.name AS tenant_name
        FROM stores s
        INNER JOIN tenants t ON t.id = s.tenant_id
        WHERE s.tenant_id = @tenantId
        ORDER BY s.created_at DESC
      '''),
      parameters: {'tenantId': tenantId},
    );

    return result.map((row) => Store.fromRow(row.toColumnMap())).toList();
  }

  /// Finds a store by id for admin detail view.
  Future<Store?> findByIdForAdmin(String id) async {
    final result = await _pool.execute(
      Sql.named('''
        SELECT s.id,
               s.tenant_id,
               s.name,
               s.slug,
               s.description,
               s.address,
               s.city,
               s.state,
               s.pincode,
               s.phone,
               s.gstin,
               s.subscription_status,
               s.subscription_started_at,
               s.subscription_expires_at,
               s.trial_expires_at,
               s.phonepe_client_id,
               s.phonepe_client_version,
               s.phonepe_client_secret,
               s.phonepe_configured,
               s.gst_enabled,
               s.is_open,
               s.is_active,
               s.created_at,
               s.updated_at,
               t.name AS tenant_name
        FROM stores s
        INNER JOIN tenants t ON t.id = s.tenant_id
        WHERE s.id = @id
        LIMIT 1
      '''),
      parameters: {'id': id},
    );

    if (result.isEmpty) {
      return null;
    }

    return Store.fromRow(result.first.toColumnMap());
  }

  /// Finds a store by id for a specific tenant.
  Future<Store?> findByIdForTenant({
    required String id,
    required String tenantId,
  }) async {
    final result = await _pool.execute(
      Sql.named('''
        SELECT s.id,
               s.tenant_id,
               s.name,
               s.slug,
               s.description,
               s.address,
               s.city,
               s.state,
               s.pincode,
               s.phone,
               s.gstin,
               s.subscription_status,
               s.subscription_started_at,
               s.subscription_expires_at,
               s.trial_expires_at,
               s.phonepe_client_id,
               s.phonepe_client_version,
               s.phonepe_client_secret,
               s.phonepe_configured,
               s.gst_enabled,
               s.is_open,
               s.is_active,
               s.created_at,
               s.updated_at,
               t.name AS tenant_name
        FROM stores s
        INNER JOIN tenants t ON t.id = s.tenant_id
        WHERE s.id = @id
          AND s.tenant_id = @tenantId
        LIMIT 1
      '''),
      parameters: {
        'id': id,
        'tenantId': tenantId,
      },
    );

    if (result.isEmpty) {
      return null;
    }

    return Store.fromRow(result.first.toColumnMap());
  }

  /// Creates a store and returns the inserted row with tenant name.
  Future<Store> create({
    required String tenantId,
    required String name,
    required String slug,
    String? description,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? phone,
    String? gstin,
  }) async {
    final result = await _pool.execute(
      Sql.named('''
        INSERT INTO stores (
          tenant_id,
          name,
          slug,
          description,
          address,
          city,
          state,
          pincode,
          phone,
          gstin
        )
        VALUES (
          @tenantId,
          @name,
          @slug,
          @description,
          @address,
          @city,
          @state,
          @pincode,
          @phone,
          @gstin
        )
        RETURNING id,
                  tenant_id,
                  name,
                  slug,
                  description,
                  address,
                  city,
                  state,
                  pincode,
                  phone,
                  gstin,
                  subscription_status,
                  subscription_started_at,
                  subscription_expires_at,
                  trial_expires_at,
                  phonepe_client_id,
                  phonepe_client_version,
                  phonepe_client_secret,
                  phonepe_configured,
                  gst_enabled,
                  is_open,
                  is_active,
                  created_at,
                  updated_at,
                  (SELECT name FROM tenants WHERE id = stores.tenant_id) AS tenant_name
      '''),
      parameters: {
        'tenantId': tenantId,
        'name': name,
        'slug': slug,
        'description': description,
        'address': address,
        'city': city,
        'state': state,
        'pincode': pincode,
        'phone': phone,
        'gstin': gstin,
      },
    );

    return Store.fromRow(result.first.toColumnMap());
  }

  /// Updates admin-governed store controls and returns updated row.
  Future<Store?> updateForAdmin({
    required String id,
    String? subscriptionStatus,
    DateTime? subscriptionStartedAt,
    DateTime? subscriptionExpiresAt,
    DateTime? trialExpiresAt,
    String? phonepeClientId,
    int? phonepeClientVersion,
    String? phonepeClientSecret,
    bool? phonepeConfigured,
    bool? gstEnabled,
    bool? isOpen,
    bool? isActive,
  }) async {
    final result = await _pool.execute(
      Sql.named('''
        UPDATE stores
        SET subscription_status = COALESCE(@subscriptionStatus, subscription_status),
            subscription_started_at = COALESCE(@subscriptionStartedAt, subscription_started_at),
            subscription_expires_at = COALESCE(@subscriptionExpiresAt, subscription_expires_at),
            trial_expires_at = COALESCE(@trialExpiresAt, trial_expires_at),
            phonepe_client_id = COALESCE(@phonepeClientId, phonepe_client_id),
            phonepe_client_version = COALESCE(@phonepeClientVersion, phonepe_client_version),
            phonepe_client_secret = COALESCE(@phonepeClientSecret, phonepe_client_secret),
            phonepe_configured = COALESCE(@phonepeConfigured, phonepe_configured),
            gst_enabled = COALESCE(@gstEnabled, gst_enabled),
            is_open = COALESCE(@isOpen, is_open),
            is_active = COALESCE(@isActive, is_active),
            updated_at = NOW()
        WHERE id = @id
        RETURNING id,
                  tenant_id,
                  name,
                  slug,
                  description,
                  address,
                  city,
                  state,
                  pincode,
                  phone,
                  gstin,
                  subscription_status,
                  subscription_started_at,
                  subscription_expires_at,
                  trial_expires_at,
                  phonepe_client_id,
                  phonepe_client_version,
                  phonepe_client_secret,
                  phonepe_configured,
                  gst_enabled,
                  is_open,
                  is_active,
                  created_at,
                  updated_at,
                  (SELECT name FROM tenants WHERE id = stores.tenant_id) AS tenant_name
      '''),
      parameters: {
        'id': id,
        'subscriptionStatus': subscriptionStatus,
        'subscriptionStartedAt': subscriptionStartedAt,
        'subscriptionExpiresAt': subscriptionExpiresAt,
        'trialExpiresAt': trialExpiresAt,
        'phonepeClientId': phonepeClientId,
        'phonepeClientVersion': phonepeClientVersion,
        'phonepeClientSecret': phonepeClientSecret,
        'phonepeConfigured': phonepeConfigured,
        'gstEnabled': gstEnabled,
        'isOpen': isOpen,
        'isActive': isActive,
      },
    );

    if (result.isEmpty) {
      return null;
    }

    return Store.fromRow(result.first.toColumnMap());
  }
}
