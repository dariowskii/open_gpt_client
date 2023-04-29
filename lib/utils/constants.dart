/// Constants used in the app.
class Constants {
  static Keys keys = const Keys();
  static InternalErrors internalErrors = const InternalErrors();
}

/// The [Keys] class holds the keys used in the app.
class Keys {
  const Keys();

  String get ghKey => 'GH_KEY';
  String get apiKey => 'apiKey';
  String get setupDone => 'setupDone';
  String get encryptedTestPhrase => 'encryptedTestPhrase';
  String get selectedChatId => 'selectedChatId';
  String get appState => 'appState';
}

/// The [InternalErrors] class holds the internal errors strings.
class InternalErrors {
  const InternalErrors();

  String get keyNotSetted => 'Key not set';
}
