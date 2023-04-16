import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:open_gpt_client/utils/app_bloc.dart';
import 'package:open_gpt_client/utils/constants.dart';
import 'package:open_gpt_client/utils/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalData {
  //#region VARIABLES

  IV? _iv;
  Encrypter? _encrypter;

  static final LocalData _instance = LocalData._();
  static LocalData get instance => _instance;

  late final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  //#endregion

  //#region CORE

  LocalData._() {
    dotenv.load();
  }

  //#endregion

  //#region GETTERS

  Future<bool?> get setupDone async {
    final prefs = await _prefs;
    return prefs.getBool(Constants.keys.setupDone);
  }

  Future<bool> get hasAPIKey async {
    final prefs = await _prefs;
    final apiKey = prefs.getString(Constants.keys.apiKey);
    return apiKey != null && apiKey.isNotEmpty;
  }

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

  String? get ghKey {
    return dotenv.env[Constants.keys.ghKey];
  }

  //#endregion

  //#region SETTERS

  Future<void> setSetupDone() async {
    final prefs = await _prefs;
    await prefs.setBool(Constants.keys.setupDone, true);
  }

  Future<void> setUserKey(String key) async {
    final encrypter = _generateEncrypter(key);
    final iv = _generateIV();

    final prefs = await _prefs;
    final memoryPhrase = prefs.getString(Constants.keys.encryptedTestPhrase);
    final encryptedPhrase = encrypter.encrypt('never gonna give you up', iv: iv);

    if (memoryPhrase == null) {
      // first setup
      await prefs.setString(Constants.keys.encryptedTestPhrase, encryptedPhrase.base64);

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

  Future<void> saveAppState(AppState state) async {
    assert(
      _iv != null && _encrypter != null,
      Constants.internalErrors.keyNotSetted,
    );

    final prefs = await _prefs;
    final json = jsonEncode(state);
    await prefs.setString(Constants.keys.appState, _encrypter!.encrypt(json, iv: _iv!).base64);
  }

  //#endregion

  //#region PUBLIC

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

  Future<void> reset() async {
    _iv = null;
    _encrypter = null;

    final prefs = await _prefs;
    await prefs.clear();
  }

  //#endregion

  //#region PRIVATE

  IV _generateIV() => IV.fromLength(16);

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

  //#endregion
}
