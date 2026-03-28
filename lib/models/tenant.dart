/// Represents a tenant (business) in the platform.
class Tenant {
  /// Creates a tenant instance.
  Tenant({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.address,
    this.city,
    this.state,
    this.pincode,
  });

  /// Creates an instance from a database row.
  factory Tenant.fromRow(Map<String, dynamic> row) => Tenant(
    id: row['id'] as String,
    name: row['name'] as String,
    email: row['email'] as String,
    phone: row['phone'] as String,
    address: row['address'] as String?,
    city: row['city'] as String?,
    state: row['state'] as String?,
    pincode: row['pincode'] as String?,
    isActive: row['is_active'] as bool,
    createdAt: row['created_at'] as DateTime,
    updatedAt: row['updated_at'] as DateTime,
  );

  /// Unique identifier of the tenant.
  final String id;

  /// Business name.
  final String name;

  /// Business email address.
  final String email;

  /// Business phone number.
  final String phone;

  /// Business address.
  final String? address;

  /// Business city.
  final String? city;

  /// Business state.
  final String? state;

  /// Postal code.
  final String? pincode;

  /// Whether tenant account is active.
  final bool isActive;

  /// Tenant creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp.
  final DateTime updatedAt;

  /// Converts this tenant into API response map.
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'address': address,
    'city': city,
    'state': state,
    'pincode': pincode,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
