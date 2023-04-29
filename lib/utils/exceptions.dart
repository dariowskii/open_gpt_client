/// Exception thrown when the key is not valid.
enum KeyExceptionType {
  wrongKey,
  wrongKeyLength,
}

/// The [KeyException] class is thrown when the key is not valid.
class KeyException implements Exception {
  final KeyExceptionType type;

  const KeyException({
    required this.type,
  });
}
