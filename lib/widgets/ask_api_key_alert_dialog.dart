import 'package:flutter/material.dart';
import 'package:open_gpt_client/extensions/context_extension.dart';
import 'package:open_gpt_client/models/local_data.dart';
import 'package:url_launcher/url_launcher.dart';

class AskAPIKeyAlertDialog extends StatefulWidget {
  const AskAPIKeyAlertDialog({super.key});

  @override
  State<AskAPIKeyAlertDialog> createState() => _AskAPIKeyAlertDialogState();
}

class _AskAPIKeyAlertDialogState extends State<AskAPIKeyAlertDialog> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                final uri =
                    Uri.parse('https://platform.openai.com/account/api-keys');
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
            controller: controller,
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
            if (controller.text.isEmpty) {
              return;
            }
            await LocalData.instance.setAPIKey(controller.text);
            if (context.mounted) {
              context.pop();
            }
          },
          child: const Text('Ok'),
        ),
      ],
    );
  }
}
