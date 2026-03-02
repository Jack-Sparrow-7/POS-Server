/// Returns `true` when [error] text contains any known DB constraint marker.
bool hasDbConstraint(Object error, List<String> markers) {
  final message = error.toString().toLowerCase();
  return markers.any(message.contains);
}
