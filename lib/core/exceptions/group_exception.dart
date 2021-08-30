class GroupException implements Exception {
  final String message;
  const GroupException(
    this.message,
  );

  @override
  String toString() => 'GroupException(message: $message)';
}
