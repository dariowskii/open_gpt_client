import 'package:flutter/material.dart';
import 'package:open_gpt_client/extensions/context_extension.dart';

class SelectedChatHeader extends StatelessWidget {
  const SelectedChatHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.appState;
    final appLocals = context.appLocals;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('${appLocals.model}: '),
          const Text(
            'gpt-3.5-turbo-0301',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '${appLocals.messagesInContext}: ',
          ),
          ValueListenableBuilder(
            valueListenable: appState,
            builder: (context, state, _) {
              return Text(
                state.selectedChat?.contextMessages.length.toString() ?? '0',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
