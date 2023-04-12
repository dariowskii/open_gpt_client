import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_gpt_client/models/api_client.dart';
import 'package:open_gpt_client/models/local_data.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_gpt_client/screens/on_boarding_screen.dart';
import 'package:open_gpt_client/screens/welcome_lock_screen.dart';
import 'package:open_gpt_client/utils/app_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final needSetup = await LocalData.instance.setupDone;
  final home = needSetup == null || !needSetup ? const OnBoardingScreen() : const WelcomeLockScreen();

  runApp(
    AppBloc(
      appState: AppStateNotifier(
        state: AppState(chats: []),
      ),
      apiService: ApiClient(),
      child: MyApp(home: home),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.home,});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Open GPT Client',
      debugShowCheckedModeBanner: kDebugMode,
      theme: ThemeData.dark(useMaterial3: true),
      home: home,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeListResolutionCallback: (locales, supportedLocales) {
        // TODO: gestione fallback del Locale in inglese
        // for (final locale in (locales ?? <Locale>[])) {
        //   if (supportedLocales
        //       .any((element) => element.languageCode == locale.languageCode)) {
        //     return locale;
        //   }
        // }

        // return const Locale('en');
      },
    );
  }
}
