/// Reason for a stock quantity change.
enum StockChangeReason {
  /// Stock was added.
  IN,

  /// Stock reduced due to a sale.
  OUT,

  /// Stock reduced due to wastage/spoilage.
  WASTAGE,

  /// Stock corrected manually.
  ADJUSTMENT,
}
