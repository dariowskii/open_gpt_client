import 'package:flutter/material.dart';
import 'package:open_gpt_client/extensions/context_extension.dart';
import 'package:open_gpt_client/models/api_client.dart';
import 'package:open_gpt_client/models/chat.dart';
import 'package:open_gpt_client/models/local_data.dart';
import 'package:open_gpt_client/screens/desktop/sidebar_home.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_gpt_client/utils/app_bloc.dart';
import 'package:open_gpt_client/widgets/chat_message_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class DesktopHomeScreen extends StatefulWidget {
  const DesktopHomeScreen({super.key});

  @override
  State<DesktopHomeScreen> createState() => _DesktopHomeScreenState();
}

class _DesktopHomeScreenState extends State<DesktopHomeScreen> {
  final _textController = TextEditingController();
  final _fieldFocusNode = FocusNode();

  var _updateAvailable = false;

  @override
  void initState() {
    super.initState();

    LocalData.instance.hasAPIKey.then((hasKey) {
      if (hasKey) {
        return;
      }

      askApiKey();
    });

    ApiClient().checkUpdate().then((updateAvailable) {
      if (!mounted) {
        return;
      }

      setState(() {
        _updateAvailable = updateAvailable;
      });
    });
  }

  void askApiKey() {
    final apiKeyController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Imposta chiave API'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Per poter utilizzare il servizio è necessario inserire una chiave API di OpenAI valida.',
              ),
              const Text(
                'Se non ne hai una, puoi richiederla qui:',
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () async {
                    final uri = Uri.parse(
                        'https://platform.openai.com/account/api-keys');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  child: const Text(
                    'https://platform.openai.com/account/api-keys',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: apiKeyController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Chiave API',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (apiKeyController.text.isEmpty) {
                  return;
                }
                await LocalData.instance.setAPIKey(apiKeyController.text);
                if (!mounted) {
                  return;
                }

                context.pop();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppBloc.of(context).appState;
    final apiService = AppBloc.of(context).apiService;
    final appLocals = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        elevation: 5,
        actions: [
          if (_updateAvailable)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton(
              onPressed: () async {
                final uri = Uri.parse(
                    'https://github.com/dariowskii/open_gpt_client/releases/latest');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
              child: Text(
                'Aggiornamento disponibile!',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          const SizedBox(
            width: 250,
            child: SidebarHome(),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: [
                  Padding(
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
                              state.selectedChat?.contextMessages.length
                                      .toString() ??
                                  '0',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  ValueListenableBuilder(
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

                      final reversedList =
                          selectedChat.messages.reversed.toList();

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
                              messageIsInContext:
                                  appState.messageIsInContext(message),
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
                  ),
                  Padding(
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
                                  onPressed: () async {
                                    final trimmedText =
                                        _textController.text.trim();
                                    if (currentState.selectedChat != null &&
                                        trimmedText.isNotEmpty) {
                                      final message = ChatMessage(
                                        id: const Uuid().v4(),
                                        senderRole: MessageSenderRole.user,
                                        content: trimmedText,
                                      );
                                      appState.addToSelectedAndContext(message);

                                      LocalData.instance
                                          .saveAppState(currentState);

                                      _textController.clear();
                                      _fieldFocusNode.unfocus();
                                      appState.addMessageToSelectedChat(
                                        ChatMessage(
                                          id: const Uuid().v4(),
                                          uniqueKeyUI:
                                              GlobalKey<ChatMessageUIState>(),
                                          senderRole:
                                              MessageSenderRole.assistant,
                                          content: '',
                                          isLoadingResponse: true,
                                        ),
                                      );

                                      final response =
                                          await apiService.sendMessages(
                                              currentState.selectedChat!);
                                      if (response != null) {
                                        appState.attachStreamToLastResponse(
                                            response);
                                      }
                                    }
                                  },
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
                        }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
