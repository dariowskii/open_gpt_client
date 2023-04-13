import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_gpt_client/extensions/context_extension.dart';
import 'package:open_gpt_client/models/chat.dart';
import 'package:open_gpt_client/models/local_data.dart';
import 'package:open_gpt_client/screens/info_screen.dart';
import 'package:open_gpt_client/screens/settings_screen.dart';
import 'package:open_gpt_client/utils/app_bloc.dart';
import 'package:uuid/uuid.dart';

class SidebarHome extends StatelessWidget {
  const SidebarHome({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppBloc.of(context).appState;
    final appLocals = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 16.0,
            bottom: 8.0,
            left: 16.0,
            right: 16.0,
          ),
          child: Text(
            appLocals.yourChats,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16.0,
          ),
          child: Divider(),
        ),
        ValueListenableBuilder(
          valueListenable: appState,
          builder: (context, state, _) {
            if (state.chats.isEmpty) {
              return const Expanded(
                child: SizedBox.shrink(),
              );
            }
            return Expanded(
              child: ListView.builder(
                itemCount: state.chats.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    mouseCursor: SystemMouseCursors.click,
                    selected: state.chats[index].id == state.selectedChat?.id,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          iconSize: 18,
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                final textController = TextEditingController(
                                  text: state.chats[index].title,
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
                                        final chat = state.chats[index];
                                        appState.editChatTitle(
                                            chat, textController.text);
                                        LocalData.instance
                                            .saveAppState(appState.value);
                                        context.pop();
                                      },
                                      child: Text(appLocals.save),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 18,
                          icon: Icon(Icons.delete, color: Colors.red[300]),
                          onPressed: () {
                            showDialog(
                              context: context,
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
                                        final chat = state.chats[index];
                                        appState.deleteChat(chat);
                                        LocalData.instance
                                            .saveAppState(appState.value);
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
                          },
                        ),
                      ],
                    ),
                    title: Text(
                      state.chats[index].title,
                      style: TextStyle(
                        fontWeight:
                            state.chats[index].id == state.selectedChat?.id
                                ? FontWeight.bold
                                : null,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      appState.selectChat(state.chats[index]);
                      LocalData.instance
                          .saveSelectedChatId(state.chats[index].id);
                    },
                  );
                },
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              final chat = Chat(
                id: const Uuid().v4(),
                title: appLocals.noChatTitle,
                messages: [],
                contextMessages: [],
              );
              appState.addChat(chat);
              appState.selectChat(chat);
              LocalData.instance.saveSelectedChatId(chat.id);
              LocalData.instance.saveAppState(appState.value);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add),
                const SizedBox(width: 8),
                Text(appLocals.addChat),
              ],
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: Text(appLocals.settings),
          onTap: () {
            context.push(const SettingsScreen());
          },
        ),
        ListTile(
          leading: const Icon(Icons.info),
          title: Text(appLocals.about),
          onTap: () {
            context.push(const InfoScreen());
          },
        ),
      ],
    );
  }
}
