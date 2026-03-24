/// Supported roles for authenticated principals in the system.
enum AuthRole {
  /// Platform-wide administrator role.
  superAdmin,

  /// Merchant role for tenant owners or operators.
  merchant,

  /// Cashier role for store-level staff.
  cashier,

  /// Customer role for end users placing orders.
  customer,
}
