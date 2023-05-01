import 'package:flutter/material.dart';
import 'package:open_gpt_client/models/api_client.dart';
import 'package:open_gpt_client/models/app_settings.dart';
import 'package:open_gpt_client/models/chat.dart';
import 'package:open_gpt_client/models/local_data.dart';

///
class AppState {
  final List<Chat> chats;
  AppSettings settings;
  Chat? get selectedChat {
    final selectedChatId = settings.selectedChatId;
    if (selectedChatId != null) {
      return chats.firstWhere((e) => e.id == selectedChatId);
    }

    return null;
  }

  bool isGenerating = false;

  AppState({
    required this.chats,
    required this.settings,
  });
}

/// The [AppStateNotifier] holds the state of the app and notifies
/// the listeners when the state changes.
class AppStateNotifier extends ValueNotifier<AppState> {
  AppStateNotifier({required AppState state}) : super(state);

  void refresh() {
    notifyListeners();
  }

  void addAndSelectChat(Chat chat) {
    value.chats.add(chat);
    value.settings.selectedChatId = chat.id;
    LocalData.instance.saveSelectedChatId(chat.id);
    notifyListeners();
  }

  void selectChat(Chat chat) {
    value.settings.selectedChatId = chat.id;
    LocalData.instance.saveSelectedChatId(chat.id);
    notifyListeners();
  }

  void deleteChat(Chat chat) {
    value.chats.remove(chat);
    value.settings.selectedChatId = value.chats.isNotEmpty ? value.chats.first.id : null;
    LocalData.instance.deleteChat(chat);
    notifyListeners();
  }

  void addMessageToSelectedChat(ChatMessage message) {
    value.selectedChat?.messages.add(message);
    notifyListeners();
  }

  void addToSelectedAndContext(ChatMessage message) {
    value.selectedChat!.messages.add(message);
    value.selectedChat!.contextMessages.add(message);
    LocalData.instance.saveChat(value.selectedChat!);
    notifyListeners();
  }

  void attachStreamToLastResponse(Stream<String> stream) {
    value.selectedChat?.messages.last.uniqueKeyUI?.currentState
        ?.attachStream(stream);
  }

  void setErrorToLastMessage() {
    value.selectedChat?.messages.last.uniqueKeyUI?.currentState
        ?.setErrorStatus();
  }

  void addMessageToContext(ChatMessage message) {
    value.selectedChat!.contextMessages.add(message);
    LocalData.instance.saveChat(value.selectedChat!);
    notifyListeners();
  }

  void removeMessageFromContext(ChatMessage message) {
    value.selectedChat?.contextMessages.remove(message);
    LocalData.instance.saveChat(value.selectedChat!);
    notifyListeners();
  }

  void deleteMessage(ChatMessage message) {
    final selectedChat = value.selectedChat!;
    selectedChat.messages.remove(message);
    selectedChat.contextMessages.remove(message);
    LocalData.instance.saveChat(selectedChat);
    notifyListeners();
  }

  bool messageIsInContext(ChatMessage message) {
    return value.selectedChat?.contextMessages.contains(message) ?? false;
  }

  void setGenerating(bool isGenerating) {
    value.isGenerating = isGenerating;
    notifyListeners();
  }

  void attachGeneratedImageToLastMessage(ChatImage image) {
    value.selectedChat?.messages.last.uniqueKeyUI?.currentState
        ?.attachGeneratedImage(image);
  }
}

/// The [AppBloc] is an [InheritedWidget] that holds the [AppStateNotifier]
/// and the [ApiService] instances.
// ignore: must_be_immutable
class AppBloc extends InheritedWidget {
  AppStateNotifier appState;
  final ApiService apiService;

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
