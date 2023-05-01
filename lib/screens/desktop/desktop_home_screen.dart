import 'package:flutter/material.dart';
import 'package:open_gpt_client/extensions/context_extension.dart';
import 'package:open_gpt_client/models/api_client.dart';
import 'package:open_gpt_client/models/local_data.dart';
import 'package:open_gpt_client/screens/desktop/sidebar_home.dart';
import 'package:open_gpt_client/widgets/ask_api_key_alert_dialog.dart';
import 'package:open_gpt_client/widgets/check_update_button.dart';
import 'package:open_gpt_client/widgets/selected_chat_action_field.dart';
import 'package:open_gpt_client/widgets/selected_chat_body.dart';
import 'package:open_gpt_client/widgets/selected_chat_header.dart';

/// The home screen for desktop.
class DesktopHomeScreen extends StatefulWidget {
  const DesktopHomeScreen({super.key});

  @override
  State<DesktopHomeScreen> createState() => _DesktopHomeScreenState();
}

class _DesktopHomeScreenState extends State<DesktopHomeScreen> {
  var _updateAvailable = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  void _init() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          content: Row(
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 8),
              Text('Sto inizializzando...'),
            ],
          ),
        );
      },
    );
    final newAppState =
        await LocalData.instance.migrateFromPrefsToConcurrentIfNecessary();
    if (newAppState != null) {
      setState(() {
        context.appState.value = newAppState;
      });
    }
    if (!mounted) {
      return;
    }
    context.pop();

    if (!LocalData.instance.hasAPIKey) {
      askApiKey();
    }

    final updateAvailable = await ApiClient().checkUpdate();
    if (!mounted) {
      return;
    }

    setState(() {
      _updateAvailable = updateAvailable;
    });
  }

  void askApiKey() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AskAPIKeyAlertDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        centerTitle: true,
        elevation: 5,
        actions: [
          if (_updateAvailable) ...[
            const CheckUpdateButton(),
          ]
        ],
      ),
      body: Row(
        children: [
          const SizedBox(
            width: 250,
            child: SidebarHome(),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: const [
                  SelectedChatHeader(),
                  SelectedChatBody(),
                  SelectedChatActionField(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
