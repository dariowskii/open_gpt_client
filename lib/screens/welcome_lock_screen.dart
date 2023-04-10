import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_gpt_client/models/local_data.dart';
import 'package:open_gpt_client/screens/home_screen.dart';
import 'package:open_gpt_client/utils/app_bloc.dart';

class WelcomeLockScreen extends StatefulWidget {
  const WelcomeLockScreen({super.key});

  @override
  State<WelcomeLockScreen> createState() => _WelcomeLockScreenState();
}

class _WelcomeLockScreenState extends State<WelcomeLockScreen> {
  var _isPasswordVisible = false;
  final _textController = TextEditingController();

  void _tryUnlock(AppLocalizations appLocals) async {
    final password = _textController.text.trim();
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocals.passwordCannotBeEmpty),
        ),
      );
      return;
    }

    final passwordLength = password.length;

    if (passwordLength != 16 && passwordLength != 24 && passwordLength != 32) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocals.errorPasswordLenght),
        ),
      );
      return;
    }

    try {
      await LocalData.instance.setUserKey(password);
      final appState = await LocalData.instance.loadAppState();

      if (!mounted) {
        return;
      }

      setState(() {
        AppBloc.of(context).appState.value = appState;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const HomeScreen();
          },
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocals.wrongPassword),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocals = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 400,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Open GPT Client',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                appLocals.insertPasswordHint,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _textController,
                obscureText: !_isPasswordVisible,
                onSubmitted: (_) => _tryUnlock(appLocals),
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: _isPasswordVisible
                          ? const Icon(Icons.visibility)
                          : const Icon(Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    )),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _tryUnlock(appLocals),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: Text(
                  appLocals.unlock,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(appLocals.resetApp),
                        content: Text(appLocals.resetAppConfirmation),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(appLocals.cancel),
                          ),
                          TextButton(
                            onPressed: () async {
                              await LocalData.instance.clear();
                              // TODO: rimandare alla schermata di tutorial
                            },
                            child: Text(
                              appLocals.confirm,
                              style: TextStyle(
                                color: Colors.red[300],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text(
                  appLocals.resetApp.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
