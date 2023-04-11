import 'package:flutter/material.dart';

class PasswordSetupScreen extends StatelessWidget {
  const PasswordSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup'),
      ),
      body: const Center(
        child: Text('PasswordSetup'),
      ),
    );
  }
}