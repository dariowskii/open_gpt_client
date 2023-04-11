import 'package:flutter/material.dart';
import 'package:password_strength_checker/password_strength_checker.dart';

class PasswordSetupScreen extends StatelessWidget {
  PasswordSetupScreen({Key? key}) : super(key: key);

  late final _passwordStrengthNotifier =
      ValueNotifier<PasswordStrengthItem?>(null);
  late final _passwordTextController = TextEditingController();
  late final _confirmTextController = TextEditingController();
  late final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Setup Password',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Please setup a password to unlock the app.',
            ),
            const SizedBox(height: 16),
            Container(
              constraints: const BoxConstraints(
                maxWidth: 400,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _passwordTextController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _passwordStrengthNotifier.value =
                            PasswordStrength.calculate(text: value);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _confirmTextController,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordTextController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    PasswordStrengthChecker(
                      strength: _passwordStrengthNotifier,
                      configuration: const PasswordStrengthCheckerConfiguration(
                        borderColor: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.maxFinite,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Processing Data')),
                            );
                          }
                        },
                        child: const Text('Submit'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
