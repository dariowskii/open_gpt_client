import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:open_gpt_client/utils/app_bloc.dart';
import 'package:open_gpt_client/utils/constants.dart';
import 'package:open_gpt_client/utils/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalData {
  IV? _iv;
  Encrypter? _encrypter;

  static final LocalData _instance = LocalData._();
  static LocalData get instance => _instance;

  late final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  LocalData._();

  Future<bool?> get setupDone async {
    final prefs = await _prefs;
    return prefs.getBool(Constants.keys.setupDone);
  }

  Future<void> setSetupDone() async {
    final prefs = await _prefs;
    await prefs.setBool(Constants.keys.setupDone, true);
  }

  Future<void> setUserKey(String key) async {
    final keyLength = key.length;
    if (keyLength != 16 && keyLength != 24 && keyLength != 32) {
      throw const KeyException(type: KeyExceptionType.wrongKeyLength);
    }

    final prefs = await _prefs;
    const testPrhase = 'never gonna give you up';
    final encryptedTestPhrase =
        prefs.getString(Constants.keys.encryptedTestPhrase);

    final iv = IV.fromLength(16);
    final encrypter = Encrypter(
      AES(
        Key.fromUtf8(key),
        mode: AESMode.ctr,
      ),
    );
    final encrypted = encrypter.encrypt(testPrhase, iv: iv);

    if (encryptedTestPhrase == null) {
      // first setup
      await prefs.setString(
          Constants.keys.encryptedTestPhrase, encrypted.base64);

      _iv = iv;
      _encrypter = encrypter;

      return;
    }

    if (encrypted.base64 != encryptedTestPhrase) {
      throw const KeyException(type: KeyExceptionType.wrongKey);
    }

    _iv = iv;
    _encrypter = encrypter;
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
    await prefs.setString(
        Constants.keys.appState, _encrypter!.encrypt(json, iv: _iv!).base64);
  }

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
}
