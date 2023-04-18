import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_gpt_client/models/api_client.dart';
import 'package:open_gpt_client/utils/app_bloc.dart';

/// Extensions for [BuildContext].
extension ContextExtension on BuildContext {
  // Blocs

  /// Returns the [AppLocalizations] of the current [BuildContext].
  AppLocalizations get appLocals => AppLocalizations.of(this)!;

  /// Returns the [AppBloc] of the current [BuildContext].
  AppBloc get appBloc => AppBloc.of(this);

  /// Returns the [AppStateNotifier] of the current [BuildContext].
  AppStateNotifier get appState => appBloc.appState;

  /// Returns the [ApiService] of the current [BuildContext].
  ApiService get apiService => appBloc.apiService;

  // MediaQuery

  /// Returns `true` if the current screen width is less than 600.
  bool get isMobile => MediaQuery.of(this).size.width < 600;

  /// Returns `true` if the current screen width is greater than or equal to 600
  /// and less than 1200.
  bool get isTablet {
    final width = MediaQuery.of(this).size.width;
    return width >= 600 && width < 1200;
  }

  /// Returns `true` if the current screen width is greater than or equal to 1200.
  bool get isDesktop => MediaQuery.of(this).size.width >= 1200;

  /// Returns the current screen width.
  double get width => MediaQuery.of(this).size.width;

  /// Returns the current screen height.
  double get height => MediaQuery.of(this).size.height;

  // Navigator

  /// Pushes a new [widget] to the current [Navigator].
  void push(Widget widget) {
    Navigator.of(this).push(
      MaterialPageRoute(
        builder: (context) => widget,
      ),
    );
  }

  /// Pushes a new [widget] to the current [Navigator] and removes all the
  /// previous routes.
  void pushAndRemoveUntil(Widget widget) {
    Navigator.of(this).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => widget,
      ),
      (route) => false,
    );
  }

  /// Pops the current [Navigator].
  void pop<T>([T? result]) {
    Navigator.of(this).pop(result);
  }

  // SnackBar

  /// Shows a [SnackBar] with the given [message].
  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
