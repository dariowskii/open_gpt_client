import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:open_gpt_client/models/app_settings.dart';
import 'package:open_gpt_client/models/chat.dart';
import 'package:open_gpt_client/utils/app_bloc.dart';
import 'package:open_gpt_client/utils/constants.dart';
import 'package:open_gpt_client/utils/exceptions.dart';
import 'package:open_gpt_client/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The [LocalData] class defines the local data of the app.
class LocalData {
  /// The [_iv] property defines the initialization vector of the encryption.
  IV? _iv;

  /// The [_encrypter] property defines the encrypter of the app.
  Encrypter? _encrypter;

  /// Private singleton constructor.
  static final LocalData _instance = LocalData._();

  /// The [instance] getter defines the instance of the singleton.
  static LocalData get instance => _instance;

  /// Private accessor to the SharedPreferences instance.
  late final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  LocalData._() {
    dotenv.load();
  }

  Future<Directory> get _documentsPath async {
    final defaultDir = await getApplicationDocumentsDirectory();
    return Directory('${defaultDir.path}/${Constants.directoryPath}');
  }

  AppSettings appSettings = AppSettings();

  Future<String?> get versionNews async {
    final prefs = await _prefs;
    return prefs.getString(Constants.keys.versionNews);
  }

  /// The [setupDone] getter defines if the setup of the app is done.
  Future<bool?> get setupDone async {
    final prefs = await _prefs;
    return prefs.getBool(Constants.keys.setupDone);
  }

  /// The [hasAPIKey] getter defines if the user has setted the API key.
  bool get hasAPIKey {
    return appSettings.apiKey != null && appSettings.apiKey!.isNotEmpty;
  }

  /// The [apiKey] getter defines the API key of the user.
  String? get apiKey {
    return appSettings.apiKey;
  }

  /// The [reducedApiKey] getter defines the reduced API key of the user.
  Future<String?> get reducedApiKey async {
    final key = apiKey;
    if (key == null) {
      return null;
    }
    final length = key.length;
    if (length < 8) {
      return key;
    }

    return '${key.substring(0, 2)}-...${key.substring(length - 4, length)}';
  }

  /// The [ghKey] getter defines the GitHub key used to check for updates.
  String? get ghKey {
    return dotenv.env[Constants.keys.ghKey];
  }

  Future<void> setVersionNews(String versionNews) async {
    final prefs = await _prefs;
    await prefs.setString(Constants.keys.versionNews, versionNews);
  }

  /// The [setSetupDone] method sets the setup of the app as done.
  Future<void> setSetupDone() async {
    final prefs = await _prefs;
    await prefs.setBool(Constants.keys.setupDone, true);
  }

  /// The [setUserKey] method sets the user key of the app.
  /// If the encryption test phrase is not setted, it means that the app is
  /// being setup for the first time, so the encryption test phrase is setted
  /// and saved.
  ///
  /// This function throws exceptions:
  /// - [KeyException] of type [KeyExceptionType.wrongKeyLength] if the key is not 16, 24 or 32 bytes long.
  /// - [KeyException] of type [KeyExceptionType.wrongKey] if the key is wrong.
  Future<void> setUserKey(String key) async {
    final encrypter = _generateEncrypter(key);
    final iv = _generateIV();

    final prefs = await _prefs;
    final encryptedTestPhrase =
        prefs.getString(Constants.keys.encryptedTestPhrase);
    if (encryptedTestPhrase != null) {
      await oldSetUserKey(key, encryptedTestPhrase, encrypter, iv);
      return;
    }

    final args = {
      'encrypter': encrypter,
      'iv': iv,
      'documentsPath': await _documentsPath,
    };

    final memoryPhrase = await compute(concurrentGetEncryptTestPhrase, args);

    if (memoryPhrase == null) {
      // first setup
      await compute(concurrentSetEncryptTestPhrase, args);

      _iv = iv;
      _encrypter = encrypter;

      return;
    }

    if (Constants.keys.testPhrase != memoryPhrase) {
      throw const KeyException(type: KeyExceptionType.wrongKey);
    }

    _iv = iv;
    _encrypter = encrypter;
  }

  Future<void> oldSetUserKey(String key, String encryptedTestPhrase,
      Encrypter encrypter, IV iv) async {
    final decryptedTestPhrase =
        encrypter.decrypt64(encryptedTestPhrase, iv: iv);

    if (Constants.keys.testPhrase != decryptedTestPhrase) {
      throw const KeyException(type: KeyExceptionType.wrongKey);
    }

    _iv = iv;
    _encrypter = encrypter;
  }

  /// The [setAPIKey] method sets the API key of the user.
  Future<void> setAPIKey(String apiKey) async {
    appSettings.apiKey = apiKey;

    await saveAppSettings(appSettings);
  }

  /// The [setSelectedChatId] method saves the current selected chat id by the user.
  Future<void> saveSelectedChatId(String chatId) async {
    appSettings.selectedChatId = chatId;

    await saveAppSettings(appSettings);
  }

  Future<void> saveChat(Chat chat) async {
    assert(
      _iv != null && _encrypter != null,
      Constants.internalErrors.keyNotSetted,
    );

    final args = {
      'encrypter': _encrypter,
      'iv': _iv,
      'chat': chat,
      'documentsPath': await _documentsPath,
    };

    await compute(concurrentSaveChat, args);
  }

  Future<void> deleteChat(Chat chat) async {
    assert(
      _iv != null && _encrypter != null,
      Constants.internalErrors.keyNotSetted,
    );

    final args = {
      'chat': chat,
      'documentsPath': await _documentsPath,
    };

    await compute(concurrentDeleteChat, args);
  }

  Future<void> saveChatImage(ChatImage chatImage) async {
    assert(
      _iv != null && _encrypter != null,
      Constants.internalErrors.keyNotSetted,
    );

    final args = {
      'encrypter': _encrypter,
      'iv': _iv,
      'image': chatImage,
      'documentsPath': await _documentsPath,
    };

    await compute(concurrentSaveImage, args);
  }

  Future<void> deleteChatImage(ChatImage chatImage) async {
    assert(
      _iv != null && _encrypter != null,
      Constants.internalErrors.keyNotSetted,
    );

    final args = {
      'image': chatImage,
      'documentsPath': await _documentsPath,
    };

    await compute(concurrentDeleteImage, args);
  }

  Future<void> saveAppSettings(AppSettings settings) async {
    assert(
      _iv != null && _encrypter != null,
      Constants.internalErrors.keyNotSetted,
    );

    final args = {
      'encrypter': _encrypter,
      'iv': _iv,
      'appSettings': settings,
      'documentsPath': await _documentsPath,
    };

    await compute(concurrentSaveAppSettings, args);
  }

  /// The [loadAppState] method loads the saved state of the app.
  Future<AppState> loadAppState() async {
    assert(
      _iv != null && _encrypter != null,
      Constants.internalErrors.keyNotSetted,
    );

    final args = {
      'encrypter': _encrypter,
      'iv': _iv,
      'documentsPath': await _documentsPath,
    };
    final appState = await compute(buildAppState, args);
    appSettings = appState.settings;
    return appState;
  }

  /// The [reset] method resets the local storage.
  Future<void> reset() async {
    _iv = null;
    _encrypter = null;

    final prefs = await _prefs;
    await prefs.clear();

    await compute(concurrentDeleteAllData, await _documentsPath);
  }

  Future<AppState?> migrateFromPrefsToConcurrentIfNecessary() async {
    assert(
      _iv != null && _encrypter != null,
      Constants.internalErrors.keyNotSetted,
    );

    final prefs = await _prefs;
    final needMigration = prefs.getBool(Constants.keys.needMigration) ?? true;

    if (!needMigration) {
      return null;
    }

    final appState = prefs.getString(Constants.keys.appState);
    if (appState == null || appState.isEmpty) {
      await prefs.setBool(Constants.keys.needMigration, false);
      return null;
    }

    final apiKey = prefs.getString(Constants.keys.apiKey);
    final selectedChatId = prefs.getString(Constants.keys.selectedChatId);
    final setupDone = prefs.getBool(Constants.keys.setupDone) ?? false;

    await prefs.clear();

    await prefs.setBool(Constants.keys.needMigration, false);
    await prefs.setBool(Constants.keys.setupDone, setupDone);

    final args = {
      'encrypter': _encrypter,
      'iv': _iv,
      'appState': appState,
      'apiKey': apiKey,
      'selectedChatId': selectedChatId,
      'documentsPath': await _documentsPath,
    };

    await compute(concurrentMigrateFromPrefs, args);
    return loadAppState();
  }

  /// Generates a random IV.
  IV _generateIV() => IV.fromLength(16);

  /// Generates an encrypter from the given [key].
  ///
  /// This function throws a [KeyException] of type [KeyExceptionType.wrongKeyLength]
  /// if the key is not 16, 24 or 32 bytes long.
  Encrypter _generateEncrypter(String key) {
    final keyLength = key.length;
    if (keyLength != 16 && keyLength != 24 && keyLength != 32) {
      throw const KeyException(type: KeyExceptionType.wrongKeyLength);
    }

    return Encrypter(
      AES(
        Key.fromUtf8(key),
        mode: AESMode.ctr,
      ),
    );
  }
}
