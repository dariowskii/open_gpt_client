import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:open_gpt_client/extensions/context_extension.dart';
import 'package:open_gpt_client/models/chat.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_gpt_client/models/local_data.dart';
import 'package:open_gpt_client/utils/app_bloc.dart';

// ignore: depend_on_referenced_packages
import 'package:flutter_highlight/themes/monokai-sublime.dart';

class ChatMessageUI extends StatefulWidget {
  const ChatMessageUI({
    super.key,
    this.messageIsInContext = false,
    required this.message,
  });

  final ChatMessage message;
  final bool messageIsInContext;

  @override
  State<ChatMessageUI> createState() => ChatMessageUIState();
}

class ChatMessageUIState extends State<ChatMessageUI> {
  StreamSubscription<String>? _subscription;
  var _isInError = false;

  void attachStream(Stream<String> stream) {
    _subscription = stream.listen((event) {
      final json = jsonDecode(event);
      final content = json["choices"][0]["delta"]["content"] as String?;
      if (content != null) {
        setState(() {
          widget.message.isLoadingResponse = false;
          widget.message.content += content;
        });
      }
    });
    _subscription?.onDone(() {
      final appState = AppBloc.of(context).appState;
      appState.addMessageToContext(widget.message);
      LocalData.instance.saveAppState(AppBloc.of(context).appState.value);
      _subscription?.cancel();
    });
  }

  void setErrorStatus() {
    setState(() {
      _isInError = true;
      widget.message.isLoadingResponse = false;
      widget.message.content =
          'Errore nel recuperare la risposta.\n\nCause possibili:\n- Connessione internet assente\n- Chiave API (OpenAI) errata\n- Non hai ancora configurato il piano a pagamento di OpenAI\n- Le API di OpenAI sono momentaneamente offline\n\nRiprova più tardi.';
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _isInError
        ? const Color.fromARGB(255, 173, 40, 22)
        : widget.message.fromMe
            ? Theme.of(context).colorScheme.surfaceVariant
            : Theme.of(context).colorScheme.primaryContainer;
    final appLocals = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  widget.message.fromMe
                      ? const CircleAvatar(
                          radius: 10,
                          child: Icon(
                            Icons.person,
                            size: 10,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.auto_awesome,
                          size: 15,
                          color: Colors.white,
                        ),
                  const SizedBox(width: 5),
                  Text(
                    widget.message.fromMe
                        ? appLocals.sentFromYou
                        : appLocals.responseFromAI,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '• ${DateFormat('dd/MM/yyyy • HH:mm').format(
                      widget.message.createdAt,
                    )}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  IconButton(
                    tooltip: appLocals.delete,
                    onPressed: () {
                      AppBloc.of(context)
                          .appState
                          .deleteMessage(widget.message);
                      LocalData.instance.saveAppState(
                        AppBloc.of(context).appState.value,
                      );
                    },
                    icon: Icon(
                      Icons.delete,
                      size: 20,
                      color:
                          _isInError ? Colors.white : const Color(0xffFF5C5C),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  IconButton(
                    tooltip: appLocals.copy,
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: widget.message.content),
                      );
                      context.showSnackBar(appLocals.copiedToClipboard);
                    },
                    icon: const Icon(
                      Icons.copy,
                      size: 17,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Text(
                    appLocals.inTheContext,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                  Checkbox(
                    value: _isInError ? false : widget.messageIsInContext,
                    onChanged: (value) {
                      if (_isInError) {
                        return;
                      }

                      final appState = AppBloc.of(context).appState;
                      if (value!) {
                        appState.addMessageToContext(widget.message);
                      } else {
                        appState.removeMessageFromContext(widget.message);
                      }
                      LocalData.instance.saveAppState(appState.value);
                    },
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(4),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          if (widget.message.isLoadingResponse) ...[
            const LinearProgressIndicator(),
          ] else ...[
            MarkdownWidget(
              data: widget.message.content,
              shrinkWrap: true,
              config: MarkdownConfig(
                configs: [
                  const PreConfig(
                    theme: monokaiSublimeTheme,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    textStyle: TextStyle(
                      fontFamily: 'monospace',
                    ),
                  ),
                  const CodeConfig(
                    style: TextStyle(
                      color: Colors.white,
                      backgroundColor: Colors.black26,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const BlockquoteConfig(
                    sideColor: Colors.white30,
                    textColor: Colors.white,
                  ),
                  TableConfig(
                    headerRowDecoration: const BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black87,
                          blurRadius: 3,
                          spreadRadius: 0,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    border: TableBorder.all(
                      color: Colors.white54,
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  const LinkConfig(
                      style: TextStyle(
                    color: Colors.blue,
                  ))
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }
}
