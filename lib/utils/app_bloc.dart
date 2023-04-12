import 'package:flutter/material.dart';
import 'package:open_gpt_client/models/api_client.dart';
import 'package:open_gpt_client/models/chat.dart';

class AppState {
  final List<Chat> chats;
  String? selectedChatId;
  Chat? get selectedChat {
    if (selectedChatId != null) {
      return chats.firstWhere((e) => e.id == selectedChatId);
    }

    return null;
  }

  AppState({
    required this.chats,
    this.selectedChatId,
  });

  // toJson

  Map<String, dynamic> toJson() {
    return {
      'chats': chats.map((e) => e.toJson()).toList(),
      'selectedChatId': selectedChatId,
    };
  }

  // fromJson

  factory AppState.fromJson(Map<String, dynamic> json) {
    return AppState(
      chats: (json['chats'] as List<dynamic>)
          .map((e) => Chat.fromJson(e as Map<String, dynamic>))
          .toList(),
      selectedChatId: json['selectedChatId'] as String?,
    );
  }
}

class AppStateNotifier extends ValueNotifier<AppState> {
  AppStateNotifier({required AppState state}) : super(state);

  void addChat(Chat chat) {
    value.chats.add(chat);
    notifyListeners();
  }

  void removeChat(Chat chat) {
    value.chats.remove(chat);
    notifyListeners();
  }

  void selectChat(Chat chat) {
    value.selectedChatId = chat.id;
    notifyListeners();
  }

  void deleteChat(Chat chat) {
    value.chats.remove(chat);
    value.selectedChatId = value.chats.isNotEmpty ? value.chats.first.id : null;
    notifyListeners();
  }

  void addMessageToSelectedChat(ChatMessage message) {
    value.selectedChat?.messages.add(message);
    notifyListeners();
  }

  void addToSelectedAndContext(ChatMessage message) {
    value.selectedChat?.messages.add(message);
    value.selectedChat?.contextMessages.add(message);
    notifyListeners();
  }

  void attachStreamToLastResponse(Stream<String> stream) {
    value.selectedChat?.messages.last.uniqueKeyUI?.currentState
        ?.attachStream(stream);
  }

  void addMessageToContext(ChatMessage message) {
    value.selectedChat?.contextMessages.add(message);
    notifyListeners();
  }

  void removeMessageFromContext(ChatMessage message) {
    value.selectedChat?.contextMessages.remove(message);
    notifyListeners();
  }

  void deleteMessage(ChatMessage message) {
    value.selectedChat?.messages.remove(message);
    value.selectedChat?.contextMessages.remove(message);
    notifyListeners();
  }

  bool messageIsInContext(ChatMessage message) {
    return value.selectedChat?.contextMessages.contains(message) ?? false;
  }

  void editChatTitle(Chat chat, String newTitle) {
    final index = value.chats.indexOf(chat);
    final newChat = value.chats[index].copyWith(title: newTitle);
    value.chats.removeAt(index);
    value.chats.insert(index, newChat);
    notifyListeners();
  }
}

// ignore: must_be_immutable
class AppBloc extends InheritedWidget {
  AppStateNotifier appState;
  ApiService apiService;

  AppBloc({
    super.key,
    required this.appState,
    required this.apiService,
    required Widget child,
  }) : super(child: child);

  static AppBloc of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppBloc>()!;
  }

  @override
  bool updateShouldNotify(covariant AppBloc oldWidget) => true;
}
