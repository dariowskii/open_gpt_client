import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_gpt_client/extensions/context_extension.dart';
import 'package:open_gpt_client/models/local_data.dart';
import 'package:open_gpt_client/screens/home_screen.dart';
import 'package:open_gpt_client/utils/app_bloc.dart';
import 'package:password_strength_checker/password_strength_checker.dart';

class PasswordSetupScreen extends StatelessWidget {
  PasswordSetupScreen({Key? key}) : super(key: key);

  late final _passwordStrengthNotifier =
      ValueNotifier<PasswordStrengthItem?>(null);
  late final _passwordTextController = TextEditingController();
  late final _confirmTextController = TextEditingController();
  late final _formKey = GlobalKey<FormState>();

  void _generatePasswordAndCopy(BuildContext context) {
    const config = PasswordGeneratorConfiguration(
      length: 32,
      minLowercase: 8,
      minUppercase: 8,
      minDigits: 8,
      minSpecial: 8,
    );
    final passGenerator = PasswordGenerator.fromConfig(configuration: config);
    final pass = passGenerator.generate();
    _passwordTextController.text = pass;
    _confirmTextController.text = pass;
    _passwordStrengthNotifier.value = PasswordStrength.calculate(text: pass);

    Clipboard.setData(ClipboardData(text: pass));
    context.showSnackBar(context.appLocals.copiedToClipboard);
  }

  void _savePasswordAndContinue(BuildContext context) async {
    context.pop();

    final password = _passwordTextController.text.trim();
    final confirm = _confirmTextController.text.trim();

    if (password != confirm) {
      return;
    }

    await LocalData.instance.setUserKey(password);
    await LocalData.instance.setSetupDone();
    final appState = await LocalData.instance.loadAppState();

    if (context.mounted) {
      AppBloc.of(context).appState.value = appState;
      context.pushReplacement(const HomeScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocals = context.appLocals;
    return Scaffold(
      body: Center(
        child: Column(
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
                          return appLocals.passwordCannotBeEmpty;
                        }
                        final length = value.trim().length;
                        if (length != 16 && length != 24 && length != 32) {
                          return appLocals.errorPasswordLenght;
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
                      decoration: InputDecoration(
                        labelText: appLocals.confirmPassword,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return appLocals.pleaseConfirmPassword;
                        }
                        if (value != _passwordTextController.text) {
                          return appLocals.passwordDoesntMatchError;
                        }

                        return null;
                      },
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
                        onPressed: () => _generatePasswordAndCopy(context),
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
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(appLocals.saveYourPasswordTitle),
                              content: Text(appLocals.saveYourPasswordText),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      _savePasswordAndContinue(context),
                                  child: Text(appLocals.forward),
                                ),
                              ],
                            ),
                          );
                        },
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
