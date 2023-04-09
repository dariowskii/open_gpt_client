import 'dart:convert';

import 'package:open_gpt_client/utils/app_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalData {
  static final LocalData _instance = LocalData._();
  static LocalData get instance => _instance;

  late final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  LocalData._();

  Future<void> saveSelectedChatId(String chatId) async {
    final prefs = await _prefs;
    await prefs.setString('selectedChatId', chatId);
  }

  Future<void> saveAppState(AppState state) async {
    final prefs = await _prefs;
    final json = jsonEncode(state);
    await prefs.setString('appState', json);
  }

  Future<AppState> loadAppState() async {
    final prefs = await _prefs;
    final json = prefs.getString('appState');
    if (json != null) {
      final state = AppState.fromJson(jsonDecode(json));
      state.selectedChatId = prefs.getString('selectedChatId') ?? state.selectedChatId;
      return state;
    } else {
      return AppState(chats: []);
    }
  }

  Future<void> clear() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}
