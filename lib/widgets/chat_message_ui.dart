import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:open_gpt_client/extensions/context_extension.dart';
import 'package:open_gpt_client/models/chat.dart';
import 'package:open_gpt_client/models/local_data.dart';

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

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Color _getBackgroudColor(BuildContext context) {
    if (widget.message.wasInError) {
      return const Color.fromARGB(255, 173, 40, 22);
    }
    final colorScheme = Theme.of(context).colorScheme;
    if (widget.message.fromMe) {
      return colorScheme.surfaceVariant;
    }
    return colorScheme.primaryContainer;
  }

  void _saveImage() async {
    final filePath = await FilePicker.platform.saveFile(
      fileName: '${widget.message.id}.png',
      type: FileType.image,
      allowedExtensions: const ['png'],
      lockParentWindow: true,
    );

    if (filePath == null) {
      return;
    }

    final file = await File(filePath).create();
    await file.writeAsBytes(widget.message.imageMessage!.imageBytes!);

    if (!mounted) {
      return;
    }
    context.showSnackBar('Immagine salvata!');
  }

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
      final appState = context.appState;
      appState.setGenerating(false);
      appState.addMessageToContext(widget.message);
      _subscription?.cancel();
    });
  }

  Future<void> attachGeneratedImage(ChatImage image) async {
    image.chatMessageId = widget.message.id;
    widget.message.imageMessage = image;
    widget.message.isLoadingResponse = false;

    setState(() {});

    if (!mounted) {
      return;
    }

    final appState = context.appState;
    appState.setGenerating(false);
    LocalData.instance.saveChat(appState.value.selectedChat!);
    LocalData.instance.saveChatImage(image);
  }

  void setErrorStatus() {
    setState(() {
      widget.message.isLoadingResponse = false;
      widget.message.wasInError = true;
      widget.message.content =
          'Errore nel recuperare la risposta.\n\nCause possibili:\n- Connessione internet assente\n- Chiave API (OpenAI) errata\n- Non hai ancora configurato il piano a pagamento di OpenAI\n- Le API di OpenAI sono momentaneamente offline\n\nRiprova più tardi.';
      LocalData.instance.saveChat(context.appState.value.selectedChat!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getBackgroudColor(context);
    final appLocals = context.appLocals;
    final appState = context.appState;

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
                  if (widget.message.messageType == MessageType.image) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.lens_blur,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Immagine generata',
                            style: TextStyle(
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    if (widget.message.fromMe) ...[
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
                    ] else ...[
                      IconButton(
                        tooltip: 'Salva immagine',
                        onPressed: _saveImage,
                        icon: const Icon(
                          Icons.download,
                          size: 17,
                          color: Colors.white,
                        ),
                      ),
                    ]
                  ],
                  IconButton(
                    tooltip: appLocals.delete,
                    onPressed: () {
                      appState.deleteMessage(widget.message);
                    },
                    icon: Icon(
                      Icons.delete,
                      size: 20,
                      color: widget.message.wasInError
                          ? Colors.white
                          : const Color(0xffFF5C5C),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  if (widget.message.messageType == MessageType.text) ...[
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
                      value: widget.message.wasInError
                          ? false
                          : widget.messageIsInContext,
                      onChanged: (value) {
                        if (widget.message.wasInError) {
                          return;
                        }

                        if (value!) {
                          appState.addMessageToContext(widget.message);
                        } else {
                          appState.removeMessageFromContext(widget.message);
                        }
                      },
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(4),
                        ),
                      ),
                    ),
                  ]
                ],
              )
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          if (widget.message.isLoadingResponse) ...[
            const LinearProgressIndicator(),
          ] else if ((widget.message.messageType == MessageType.image &&
                  widget.message.fromMe) ||
              widget.message.messageType == MessageType.text) ...[
            _CustomMarkDown(content: widget.message.content),
          ] else if (widget.message.messageType == MessageType.image &&
              !widget.message.fromMe) ...[
            if (widget.message.imageMessage?.imageBytes != null) ...[
              _ChatMessageImageBody(message: widget.message.imageMessage!),
            ] else ...[
              const _CustomMarkDown(content: 'Immagine non disponibile'),
            ]
          ]
        ],
      ),
    );
  }
}

class _ChatMessageImageBody extends StatelessWidget {
  const _ChatMessageImageBody({
    required this.message,
  });

  final ChatImage message;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 300,
            height: 300,
            child: Image.memory(
              message.imageBytes!,
              cacheHeight: 300,
              cacheWidth: 300,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                text: 'ID: ',
                children: [
                  TextSpan(
                    text: message.id,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                text: 'Dimensione: ',
                children: [
                  TextSpan(
                    text: message.size.apiSize,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                text: 'Peso: ',
                children: [
                  TextSpan(
                    text: message.imageSize,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Text.rich(
              TextSpan(
                text: 'Formato: ',
                children: [
                  TextSpan(
                    text: 'PNG',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                const Text('Costo: '),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onBackground,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    message.size.cost,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.background,
                    ),
                  ),
                )
              ],
            )
          ],
        )
      ],
    );
  }
}

class _CustomMarkDown extends StatelessWidget {
  const _CustomMarkDown({
    Key? key,
    required this.content,
  }) : super(key: key);

  final String content;

  @override
  Widget build(BuildContext context) {
    return MarkdownWidget(
      data: content,
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
    );
  }
}
