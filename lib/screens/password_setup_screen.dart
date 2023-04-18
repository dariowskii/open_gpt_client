import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_gpt_client/extensions/context_extension.dart';
import 'package:open_gpt_client/models/local_data.dart';
import 'package:open_gpt_client/screens/home_screen.dart';
import 'package:password_strength_checker/password_strength_checker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PasswordSetupScreen extends StatefulWidget {
  const PasswordSetupScreen({Key? key}) : super(key: key);

  @override
  State<PasswordSetupScreen> createState() => _PasswordSetupScreenState();
}

class _PasswordSetupScreenState extends State<PasswordSetupScreen> {
  late final _passwordStrengthNotifier =
      ValueNotifier<PasswordStrengthItem?>(null);
  late final _passwordTextController = TextEditingController();
  late final _confirmTextController = TextEditingController();
  late final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _passwordTextController.dispose();
    _confirmTextController.dispose();
    _passwordStrengthNotifier.dispose();
    super.dispose();
  }

  void _generatePasswordAndCopy() {
    const config = PasswordGeneratorConfiguration(
      length: 32,
      minLowercase: 8,
      minUppercase: 8,
      minDigits: 8,
      minSpecial: 8,
    );
    final passGenerator = PasswordGenerator.fromConfig(configuration: config);
    var pass = '';
    while (utf8.encode(pass).length != 32) {
      pass = passGenerator.generate();
    }
    _passwordTextController.text = pass;
    _confirmTextController.text = pass;
    _passwordStrengthNotifier.value = PasswordStrength.calculate(text: pass);

    Clipboard.setData(ClipboardData(text: pass));
    context.showSnackBar(context.appLocals.copiedToClipboard);
  }

  void _askConfirmForPassword(AppLocalizations appLocals) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(appLocals.saveYourPasswordTitle),
        content: Text(appLocals.saveYourPasswordText),
        actions: [
          TextButton(
            onPressed: () => _savePasswordAndContinue(dialogContext),
            child: Text(appLocals.forward),
          ),
        ],
      ),
    );
  }

  void _savePasswordAndContinue(BuildContext dialogContext) async {
    dialogContext.pop();

    final password = _passwordTextController.text.trim();
    final confirm = _confirmTextController.text.trim();

    if (password != confirm) {
      return;
    }

    await LocalData.instance.setUserKey(password);
    await LocalData.instance.setSetupDone();
    final appState = await LocalData.instance.loadAppState();

    if (!mounted) {
      return;
    }

    setState(() {
      context.appState.value = appState;
    });
    context.pushAndRemoveUntil(const HomeScreen());
  }

  @override
  Widget build(BuildContext context) {
    final appLocals = context.appLocals;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _Header(),
            Container(
              constraints: const BoxConstraints(
                maxWidth: 400,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _PasswordTextField(
                      controller: _passwordTextController,
                      passwordStrengthNotifier: _passwordStrengthNotifier,
                    ),
                    const SizedBox(height: 10),
                    _ConfirmTextField(
                      controller: _confirmTextController,
                      passwordTextController: _passwordTextController,
                    ),
                    const SizedBox(height: 10),
                    PasswordStrengthChecker(
                      strength: _passwordStrengthNotifier,
                      configuration: const PasswordStrengthCheckerConfiguration(
                        borderColor: Colors.white70,
                        showStatusWidget: false,
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
                        onPressed: _generatePasswordAndCopy,
                        child: Text(appLocals.generatePassword),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.maxFinite,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => _askConfirmForPassword(appLocals),
                        child: Text(
                          appLocals.confirm,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
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

class _Header extends StatelessWidget {
  const _Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appLocals = context.appLocals;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Setup Password',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 10),
            Icon(
              Icons.lock,
            )
          ],
        ),
        const SizedBox(height: 32),
        Text(
          appLocals.setupPasswordHeadline,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _PasswordTextField extends StatelessWidget {
  const _PasswordTextField({
    Key? key,
    required this.controller,
    required this.passwordStrengthNotifier,
  }) : super(key: key);

  final TextEditingController controller;
  final ValueNotifier<PasswordStrengthItem?> passwordStrengthNotifier;

  @override
  Widget build(BuildContext context) {
    final appLocals = context.appLocals;
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return appLocals.passwordCannotBeEmpty;
        }
        final length = value.trim().length;
        if (length != 16 && length != 24 && length != 32) {
          return appLocals.errorPasswordLenght;
        }

        return null;
      },
      onChanged: (value) {
        passwordStrengthNotifier.value =
            PasswordStrength.calculate(text: value);
      },
    );
  }
}

class _ConfirmTextField extends StatelessWidget {
  const _ConfirmTextField({
    Key? key,
    required this.controller,
    required this.passwordTextController,
  }) : super(key: key);

  final TextEditingController controller;
  final TextEditingController passwordTextController;

  @override
  Widget build(BuildContext context) {
    final appLocals = context.appLocals;
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: appLocals.confirmPassword,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return appLocals.pleaseConfirmPassword;
        }
        if (value != passwordTextController.text) {
          return appLocals.passwordDoesntMatchError;
        }

        return null;
      },
    );
  }
}
