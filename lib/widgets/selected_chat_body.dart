import 'package:flutter/material.dart';
import 'package:open_gpt_client/extensions/context_extension.dart';
import 'package:open_gpt_client/widgets/chat_message_ui.dart';

class SelectedChatBody extends StatelessWidget {
  const SelectedChatBody({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.appState;
    final appLocals = context.appLocals;

    return ValueListenableBuilder(
      valueListenable: appState,
      builder: (context, state, _) {
        if (state.selectedChat == null) {
          return const Expanded(
            child: SizedBox.shrink(),
          );
        }
        final selectedChat = state.selectedChat!;

        if (selectedChat.messages.isEmpty) {
          return Expanded(
            child: Center(
              child: Text(
                appLocals.noMessages,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final reversedList = selectedChat.messages.reversed.toList();

        return Expanded(
          child: ListView.separated(
            addAutomaticKeepAlives: false,
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
            ),
            itemCount: selectedChat.messages.length,
            reverse: true,
            itemBuilder: (context, index) {
              final message = reversedList[index];
              return ChatMessageUI(
                key: message.uniqueKeyUI,
                message: message,
                messageIsInContext: appState.messageIsInContext(message),
              );
            },
            separatorBuilder: (context, index) {
              return const SizedBox(
                height: 8,
              );
            },
          ),
        );
      },
    );
  }
}
