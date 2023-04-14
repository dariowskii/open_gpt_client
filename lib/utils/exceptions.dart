enum KeyExceptionType {
  wrongKey,
  wrongKeyLength,
}

class KeyException implements Exception {
  final KeyExceptionType type;

  const KeyException({
    required this.type,
  });
}
