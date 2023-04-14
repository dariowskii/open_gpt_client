import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_gpt_client/utils/app_bloc.dart';

extension ContextExtension on BuildContext {
  // Blocs

  AppLocalizations get appLocals => AppLocalizations.of(this)!;
  AppBloc get appBloc => AppBloc.of(this);
  AppStateNotifier get appState => appBloc.appState;

  // MediaQuery

  bool get isMobile => MediaQuery.of(this).size.width < 600;
  bool get isTablet {
    final width = MediaQuery.of(this).size.width;
    return width >= 600 && width < 1200;
  }

  bool get isDesktop => MediaQuery.of(this).size.width >= 1200;

  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;

  // Navigator

  void push(Widget widget) {
    Navigator.of(this).push(
      MaterialPageRoute(
        builder: (context) => widget,
      ),
    );
  }

  void pushReplacement(Widget widget) {
    Navigator.of(this).pushReplacement(
      MaterialPageRoute(
        builder: (context) => widget,
      ),
    );
  }

  void pop<T>([T? result]) {
    Navigator.of(this).pop();
  }

  // SnackBar

  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
