import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  bool get isMobile => MediaQuery.of(this).size.width < 600;

  bool get isTablet {
    final width = MediaQuery.of(this).size.width;
    return width >= 600 && width < 1200;
  }

  bool get isDesktop => MediaQuery.of(this).size.width >= 1200;
}