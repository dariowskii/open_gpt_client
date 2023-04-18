import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:open_gpt_client/utils/app_bloc.dart';
import 'package:open_gpt_client/utils/constants.dart';
import 'package:open_gpt_client/utils/exceptions.dart';
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

  /// Priate accessor to the SharedPreferences instance.
  late final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  LocalData._() {
    dotenv.load();
  }

  /// The [setupDone] getter defines if the setup of the app is done.
  Future<bool?> get setupDone async {
    final prefs = await _prefs;
    return prefs.getBool(Constants.keys.setupDone);
  }

  /// The [hasAPIKey] getter defines if the user has setted the API key.
  Future<bool> get hasAPIKey async {
    final prefs = await _prefs;
    final apiKey = prefs.getString(Constants.keys.apiKey);
    return apiKey != null && apiKey.isNotEmpty;
  }

  /// The [apiKey] getter defines the API key of the user.
  Future<String?> get apiKey async {
    assert(
      _iv != null && _encrypter != null,
      Constants.internalErrors.keyNotSetted,
    );

    final prefs = await _prefs;
    return _encrypter!.decrypt64(
      prefs.getString(Constants.keys.apiKey)!,
      iv: _iv!,
    );
  }

  /// The [reducedApiKey] getter defines the reduced API key of the user.
  Future<String?> get reducedApiKey async {
    final key = await apiKey;
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
    final memoryPhrase = prefs.getString(Constants.keys.encryptedTestPhrase);
    final encryptedPhrase =
        encrypter.encrypt('never gonna give you up', iv: iv);

    if (memoryPhrase == null) {
      // first setup
      await prefs.setString(
          Constants.keys.encryptedTestPhrase, encryptedPhrase.base64);

      _iv = iv;
      _encrypter = encrypter;

      return;
    }

    if (encryptedPhrase.base64 != memoryPhrase) {
      throw const KeyException(type: KeyExceptionType.wrongKey);
    }

    _iv = iv;
    _encrypter = encrypter;
  }

  /// The [setAPIKey] method sets the API key of the user.
  Future<void> setAPIKey(String apiKey) async {
    assert(
      _iv != null && _encrypter != null,
      Constants.internalErrors.keyNotSetted,
    );

    final prefs = await _prefs;
    await prefs.setString(
      Constants.keys.apiKey,
      _encrypter!.encrypt(apiKey, iv: _iv!).base64,
    );
  }

  /// The [setSelectedChatId] method saves the current selected chat id by the user.
  Future<void> saveSelectedChatId(String chatId) async {
    assert(
      _iv != null && _encrypter != null,
      Constants.internalErrors.keyNotSetted,
    );

    final prefs = await _prefs;
    await prefs.setString(
      Constants.keys.selectedChatId,
      _encrypter!.encrypt(chatId, iv: _iv!).base64,
    );
  }

  /// The [saveAppState] method saves the current state of the app.
  Future<void> saveAppState(AppState state) async {
    assert(
      _iv != null && _encrypter != null,
      Constants.internalErrors.keyNotSetted,
    );

    final prefs = await _prefs;
    final json = jsonEncode(state);
    await prefs.setString(
        Constants.keys.appState, _encrypter!.encrypt(json, iv: _iv!).base64);
  }

  /// The [loadAppState] method loads the saved state of the app.
  Future<AppState> loadAppState() async {
    assert(
      _iv != null && _encrypter != null,
      Constants.internalErrors.keyNotSetted,
    );

    final prefs = await _prefs;
    final json = prefs.getString(Constants.keys.appState);
    if (json != null) {
      final decrypted = _encrypter!.decrypt64(json, iv: _iv!);
      final state = AppState.fromJson(jsonDecode(decrypted));
      final selectedChatId = prefs.getString(Constants.keys.selectedChatId);
      if (selectedChatId != null) {
        state.selectedChatId = _encrypter!.decrypt64(selectedChatId, iv: _iv!);
      }
      return state;
    }

    return AppState(chats: []);
  }

  /// The [reset] method resets the local storage.
  Future<void> reset() async {
    _iv = null;
    _encrypter = null;

    final prefs = await _prefs;
    await prefs.clear();
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
