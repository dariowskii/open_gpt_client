import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportMeCard extends StatelessWidget {
  const SupportMeCard({super.key});

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openAtobitPage() async {
    _launchUrl('https://www.atobit.it/');
  }

  void _openLinkedinPage() async {
    _launchUrl('https://www.linkedin.com/in/dario-varriale/');
  }

  void _openPaypalPage() async {
    _launchUrl('https://paypal.me/dariovarriale');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                "assets/img/linkedin_pic.png",
                width: 100,
                height: 100,
                filterQuality: FilterQuality.high,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dario Varriale',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text.rich(
                  TextSpan(
                      text: 'iOS Developer && Flutter Developer @ ',
                      children: [
                        TextSpan(
                          text: 'Atobit',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = _openAtobitPage,
                        ),
                      ]),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => _openLinkedinPage(),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF0072b1),
                      ),
                      child: const Text('Seguimi su LinkedIn'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => _openPaypalPage(),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF3b7bbf),
                      ),
                      child: const Text('Dona su PayPal'),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
