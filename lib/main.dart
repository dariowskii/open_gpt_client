import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_gpt_client/models/local_data.dart';
import 'package:open_gpt_client/screens/home_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_gpt_client/utils/app_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalData.instance.setUserKey('1234567890123456');
  final appState = await LocalData.instance.loadAppState();

  runApp(
    AppBloc(
      appState: AppStateNotifier(
        state: appState,
      ),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Open GPT Client',
      debugShowCheckedModeBanner: kDebugMode,
      theme: ThemeData.dark(useMaterial3: true),
      home: const HomeScreen(),
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
