import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:open_gpt_client/utils/app_bloc.dart';
import 'package:open_gpt_client/utils/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalData {
  IV? _iv;
  Encrypter? _encrypter;

  static final LocalData _instance = LocalData._();
  static LocalData get instance => _instance;

  late final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  LocalData._();

  Future<void> setUserKey(String key) async {
    assert(
      key.length == 16 || key.length == 24 || key.length == 32,
      'Key length must be 16, 24 or 32',
    );

    final prefs = await _prefs;
    const testPrhase = 'never gonna give you up';
    final encryptedTestPhrase = prefs.getString('encryptedTestPhrase');

    final iv = IV.fromLength(16);
    final encrypter = Encrypter(
      AES(
        Key.fromUtf8(key),
        mode: AESMode.ctr,
      ),
    );
    final encrypted = encrypter.encrypt(testPrhase, iv: iv);

    if (encryptedTestPhrase == null) {
      // primo setup
      await prefs.setString('encryptedTestPhrase', encrypted.base64);

      _iv = iv;
      _encrypter = encrypter;

      return;
    }

    if (encrypted.base64 != encryptedTestPhrase) {
      throw WrongKeyException();
    }

    _iv = iv;
    _encrypter = encrypter;
  }

  Future<void> saveSelectedChatId(String chatId) async {
    assert(
      _iv != null && _encrypter != null,
      'Key not set',
    );

    final prefs = await _prefs;
    await prefs.setString(
        'selectedChatId', _encrypter!.encrypt(chatId, iv: _iv!).base64);
  }

  Future<void> saveAppState(AppState state) async {
    assert(
      _iv != null && _encrypter != null,
      'Key not set',
    );

    final prefs = await _prefs;
    final json = jsonEncode(state);
    await prefs.setString(
        'appState', _encrypter!.encrypt(json, iv: _iv!).base64);
  }

  Future<AppState> loadAppState() async {
    assert(
      _iv != null && _encrypter != null,
      'Key not set',
    );

    final prefs = await _prefs;
    final json = prefs.getString('appState');
    if (json != null) {
      final decrypted = _encrypter!.decrypt64(json, iv: _iv!);
      final state = AppState.fromJson(jsonDecode(decrypted));
      final selectedChatId = prefs.getString('selectedChatId');
      if (selectedChatId != null) {
        state.selectedChatId = _encrypter!.decrypt64(selectedChatId, iv: _iv!);
      }
      return state;
    } 
    
    return AppState(chats: []);
  }

  Future<void> clear() async {
    _iv = null;
    _encrypter = null;

    final prefs = await _prefs;
    await prefs.clear();
  }
}
