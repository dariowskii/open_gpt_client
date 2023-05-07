import 'package:flutter/material.dart';
import 'package:open_gpt_client/extensions/context_extension.dart';
import 'package:open_gpt_client/screens/info_screen.dart';
import 'package:open_gpt_client/screens/settings_screen.dart';
import 'package:open_gpt_client/widgets/add_chat_button.dart';
import 'package:open_gpt_client/widgets/sidebar_chat_item.dart';

/// The home sidebar for desktop.
class SidebarHome extends StatelessWidget {
  const SidebarHome({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.appState;
    final appLocals = context.appLocals;

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
                itemBuilder: (_, index) => SidebarChatItem(
                  chat: state.chats[index],
                  isSelected: state.selectedChat?.id == state.chats[index].id,
                ),
              ),
            );
          },
        ),
        ValueListenableBuilder(
          valueListenable: appState,
          builder: (context, state, _) {
            return Column(
              children: [
                const AddChatButton(),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: Text(appLocals.settings),
                  onTap: state.isGenerating ? null : () {
                    context.push(const SettingsScreen());
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: Text(appLocals.about),
                  onTap: state.isGenerating ? null : () {
                    context.push(const InfoScreen());
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
