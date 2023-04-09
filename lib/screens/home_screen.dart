import 'package:flutter/material.dart';
import 'package:open_gpt_client/extensions/context_extension.dart';
import 'package:open_gpt_client/screens/desktop/desktop_home_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) {
      return const Placeholder();
    } else {
      return const DesktopHomeScreen();
    }
  }
}
