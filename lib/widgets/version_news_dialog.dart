import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:open_gpt_client/extensions/context_extension.dart';
import 'package:open_gpt_client/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class VersionNewsDialog extends StatelessWidget {
  const VersionNewsDialog({Key? key}) : super(key: key);

  void _openGithubIssue() async {
    final uri =
        Uri.parse('https://github.com/dariowskii/open_gpt_client/issues/3');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novità della versione - ${Constants.appVersion}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• Genera le immagini utilizzando DALL•E! 🤖',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Text.rich(
            TextSpan(
              text: '   Vai nelle ',
              children: [
                WidgetSpan(
                  child: Icon(
                    Icons.settings,
                    size: 16,
                  ),
                ),
                TextSpan(
                  text: ' Impostazioni ',
                ),
                WidgetSpan(
                  child: Icon(
                    Icons.arrow_right,
                    size: 16,
                  ),
                ),
                TextSpan(
                  text:
                      ' Generazione Immagini (DALL•E) per impostare la grandezza\n   delle immagini generate (e di conseguenza il costo).',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              text:
                  '• Risolto un bug nella generazione della password in fase iniziale (',
              style: const TextStyle(
                fontSize: 16,
              ),
              children: [
                WidgetSpan(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.bug_report,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                    ],
                  ),
                ),
                TextSpan(
                    text: '#3',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = _openGithubIssue),
                const TextSpan(
                  text: ')',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '• Miglioramento delle prestazioni.',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.pop();
          },
          child: const Text('Chiudi'),
        ),
      ],
    );
  }
}
