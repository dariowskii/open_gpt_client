import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:open_gpt_client/widgets/support_me_card.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  void _openGithubRepo() async {
    final uri = Uri.parse('https://github.com/dariowskii/open_gpt_client');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Info'),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Open GPT Client',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text.rich(
                TextSpan(text: 'Open GPT Client è un software ', children: [
                  TextSpan(
                    text: 'open source',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                        ' che ti permette di interagire con le API di OpenAI (in particolare con ',
                  ),
                  TextSpan(
                    text: 'ChatGPT 3.5',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ') in maniera semplice e gratuita ',
                  ),
                  TextSpan(
                    text: 'senza raccogliere dati personali.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text.rich(
                TextSpan(
                  text:
                      'Tutti i dati salvati in locale sono criptati con algoritmo ',
                  children: [
                    TextSpan(
                      text: 'AES-256',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ' e non vengono mai inviati a server remoti.',
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text.rich(
                TextSpan(
                    text: 'Il codice sorgente è disponibile su ',
                    children: [
                      TextSpan(
                        text: 'GitHub',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = _openGithubRepo,
                      ),
                      const TextSpan(
                        text: ' e puoi contribuire al progetto ',
                      ),
                      const TextSpan(
                        text: 'apportando modifiche',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(
                        text: ' o ',
                      ),
                      const TextSpan(
                        text: 'segnalando bug',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(
                        text: '.',
                      ),
                    ]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Supporta il progetto',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const SupportMeCard(),
            ],
          ),
        ),
      ),
    );
  }
}
