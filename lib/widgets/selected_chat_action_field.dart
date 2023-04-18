import 'package:flutter/material.dart';
import 'package:open_gpt_client/extensions/context_extension.dart';
import 'package:open_gpt_client/models/api_client.dart';
import 'package:open_gpt_client/models/chat.dart';
import 'package:open_gpt_client/models/local_data.dart';
import 'package:open_gpt_client/utils/app_bloc.dart';
import 'package:open_gpt_client/widgets/chat_message_ui.dart';
import 'package:uuid/uuid.dart';

class SelectedChatActionField extends StatefulWidget {
  const SelectedChatActionField({super.key});

  @override
  State<SelectedChatActionField> createState() =>
      _SelectedChatActionFieldState();
}

class _SelectedChatActionFieldState extends State<SelectedChatActionField> {
  late final _textController = TextEditingController();
  late final _fieldFocusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _fieldFocusNode.dispose();
    super.dispose();
  }

  void _onSend(AppState currentState, AppStateNotifier appState,
      ApiService apiService) async {
    final trimmedText = _textController.text.trim();
    if (currentState.selectedChat != null && trimmedText.isNotEmpty) {
      final message = ChatMessage(
        id: const Uuid().v4(),
        senderRole: MessageSenderRole.user,
        content: trimmedText,
      );
      appState.addToSelectedAndContext(message);

      LocalData.instance.saveAppState(currentState);

      _textController.clear();
      _fieldFocusNode.unfocus();
      appState.addMessageToSelectedChat(
        ChatMessage(
          id: const Uuid().v4(),
          uniqueKeyUI: GlobalKey<ChatMessageUIState>(),
          senderRole: MessageSenderRole.assistant,
          content: '',
          isLoadingResponse: true,
        ),
      );

      final response =
          await apiService.sendMessages(currentState.selectedChat!);
      if (response != null) {
        appState.attachStreamToLastResponse(response);
        return;
      }

      appState.setErrorToLastMessage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.appState;
    final appLocals = context.appLocals;
    final apiService = context.apiService;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ValueListenableBuilder(
        valueListenable: appState,
        builder: (context, currentState, _) {
          return TextField(
            maxLines: 10,
            minLines: 1,
            maxLength: 1000,
            controller: _textController,
            focusNode: _fieldFocusNode,
            enabled: currentState.selectedChat != null,
            decoration: InputDecoration(
              border: const OutlineInputBorder(gapPadding: 12),
              hintText: appLocals.dasboardFieldInput,
              suffix: Container(
                margin: const EdgeInsets.only(right: 8),
                child: ElevatedButton(
                  onPressed: () => _onSend(currentState, appState, apiService),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(appLocals.send),
                      const SizedBox(width: 8),
                      const Icon(Icons.send, size: 15),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
