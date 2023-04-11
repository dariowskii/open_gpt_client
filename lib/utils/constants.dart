class Constants {
  static Keys keys = const Keys();
  static InternalErrors internalErrors = const InternalErrors();
}

class Keys {
  const Keys();

  String get setupDone => 'setupDone';
  String get encryptedTestPhrase => 'encryptedTestPhrase';
  String get selectedChatId => 'selectedChatId';
  String get appState => 'appState';
}

class InternalErrors {
  const InternalErrors();

  String get keyNotSetted => 'Key not set';
}