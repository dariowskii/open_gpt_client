import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckUpdateButton extends StatelessWidget {
  const CheckUpdateButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}
