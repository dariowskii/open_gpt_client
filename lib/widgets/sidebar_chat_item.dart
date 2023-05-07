import 'package:flutter/material.dart';
import 'package:open_gpt_client/extensions/context_extension.dart';
import 'package:open_gpt_client/models/chat.dart';
import 'package:open_gpt_client/models/local_data.dart';
import 'package:open_gpt_client/utils/app_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SidebarChatItem extends StatelessWidget {
  const SidebarChatItem({
    super.key,
    required this.chat,
    required this.isSelected,
  });

  final Chat chat;
  final bool isSelected;

  void _editTitle(BuildContext widgetContext, AppStateNotifier appState,
      AppLocalizations appLocals) {
    showDialog(
      context: widgetContext,
      builder: (context) {
        final textController = TextEditingController(
          text: chat.title,
        );
        return AlertDialog(
          title: Text(appLocals.modifyChatTitle),
          content: TextField(
            controller: textController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: appLocals.newTitle,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: Text(
                appLocals.cancel,
                style: TextStyle(
                  color: Colors.red[300],
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                chat.title = textController.text;
                appState.refresh();
                LocalData.instance.saveChat(chat);
                context.pop();
              },
              child: Text(appLocals.save),
            ),
          ],
        );
      },
    );
  }

  void _deleteChat(BuildContext widgetContext, AppStateNotifier appState,
      AppLocalizations appLocals) {
    showDialog(
      context: widgetContext,
      builder: (context) {
        return AlertDialog(
          title: Text(appLocals.deleteChatTitle),
          content: Text(appLocals.deleteChatQuestion),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: Text(appLocals.back),
            ),
            TextButton(
              onPressed: () {
                appState.deleteChat(chat);
                context.pop();
              },
              child: Text(
                appLocals.delete,
                style: TextStyle(
                  color: Colors.red[300],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _selectChat(AppStateNotifier appState) {
    appState.selectChat(chat);
  }

  @override
  Widget build(BuildContext context) {
    final appLocals = context.appLocals;
    final appState = context.appState;

    return ValueListenableBuilder(
        valueListenable: appState,
        builder: (context, state, _) {
          return ListTile(
            mouseCursor: SystemMouseCursors.click,
            selected: isSelected,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  iconSize: 18,
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.edit),
                  onPressed: state.isGenerating
                      ? null
                      : () => _editTitle(context, appState, appLocals),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 18,
                  icon: Icon(Icons.delete,
                      color: isSelected ? Colors.red[300] : null),
                  onPressed: state.isGenerating
                      ? null
                      : () => _deleteChat(context, appState, appLocals),
                ),
              ],
            ),
            title: Text(
              chat.title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : null,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            onTap: state.isGenerating ? null : () => _selectChat(appState),
          );
        });
  }
}
