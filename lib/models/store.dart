/// Represents a store under a tenant.
class Store {
  /// Creates a store instance.
  Store({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.slug,
    required this.subscriptionStatus,
    required this.phonepeConfigured,
    required this.gstEnabled,
    required this.isOpen,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.phone,
    this.gstin,
    this.subscriptionStartedAt,
    this.subscriptionExpiresAt,
    this.trialExpiresAt,
    this.phonepeClientId,
    this.phonepeClientVersion,
    this.phonepeClientSecret,
    this.tenantName,
  });

  /// Creates an instance from a database row.
  factory Store.fromRow(Map<String, dynamic> row) => Store(
    id: row['id'] as String,
    tenantId: row['tenant_id'] as String,
    name: row['name'] as String,
    slug: row['slug'] as String,
    description: row['description'] as String?,
    address: row['address'] as String?,
    city: row['city'] as String?,
    state: row['state'] as String?,
    pincode: row['pincode'] as String?,
    phone: row['phone'] as String?,
    gstin: row['gstin'] as String?,
    subscriptionStatus: row['subscription_status'] as String,
    subscriptionStartedAt: row['subscription_started_at'] as DateTime?,
    subscriptionExpiresAt: row['subscription_expires_at'] as DateTime?,
    trialExpiresAt: row['trial_expires_at'] as DateTime?,
    phonepeClientId: row['phonepe_client_id'] as String?,
    phonepeClientVersion: row['phonepe_client_version'] as int?,
    phonepeClientSecret: row['phonepe_client_secret'] as String?,
    phonepeConfigured: row['phonepe_configured'] as bool,
    gstEnabled: row['gst_enabled'] as bool,
    isOpen: row['is_open'] as bool,
    isActive: row['is_active'] as bool,
    createdAt: row['created_at'] as DateTime,
    updatedAt: row['updated_at'] as DateTime,
    tenantName: row['tenant_name'] as String?,
  );

  /// Store identifier.
  final String id;

  /// Parent tenant identifier.
  final String tenantId;

  /// Store name.
  final String name;

  /// Public store slug.
  final String slug;

  /// Optional store description.
  final String? description;

  /// Optional address.
  final String? address;

  /// Optional city.
  final String? city;

  /// Optional state.
  final String? state;

  /// Optional pincode.
  final String? pincode;

  /// Optional phone.
  final String? phone;

  /// Optional GSTIN.
  final String? gstin;

  /// Subscription status value.
  final String subscriptionStatus;

  /// Subscription start timestamp.
  final DateTime? subscriptionStartedAt;

  /// Subscription expiry timestamp.
  final DateTime? subscriptionExpiresAt;

  /// Trial expiry timestamp.
  final DateTime? trialExpiresAt;

  /// PhonePe client id.
  final String? phonepeClientId;

  /// PhonePe client version.
  final int? phonepeClientVersion;

  /// PhonePe client secret.
  final String? phonepeClientSecret;

  /// Whether PhonePe is configured.
  final bool phonepeConfigured;

  /// Whether GST is enabled for this store.
  final bool gstEnabled;

  /// Whether store is currently open.
  final bool isOpen;

  /// Whether store is active.
  final bool isActive;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp.
  final DateTime updatedAt;

  /// Tenant name from joined admin query.
  final String? tenantName;

  /// Serializes this store for API responses.
  Map<String, dynamic> toMap() => {
    'id': id,
    'tenantId': tenantId,
    'tenantName': tenantName,
    'name': name,
    'slug': slug,
    'description': description,
    'address': address,
    'city': city,
    'state': state,
    'pincode': pincode,
    'phone': phone,
    'gstin': gstin,
    'subscriptionStatus': subscriptionStatus,
    'subscriptionStartedAt': subscriptionStartedAt?.toIso8601String(),
    'subscriptionExpiresAt': subscriptionExpiresAt?.toIso8601String(),
    'trialExpiresAt': trialExpiresAt?.toIso8601String(),
    'phonepeClientId': phonepeClientId,
    'phonepeClientVersion': phonepeClientVersion,
    'phonepeClientSecret': phonepeClientSecret,
    'phonepeConfigured': phonepeConfigured,
    'gstEnabled': gstEnabled,
    'isOpen': isOpen,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
