import 'package:efood_multivendor/util/app_constants.dart';
import 'package:flutter/material.dart';

ThemeData dark = ThemeData(
  fontFamily: AppConstants.fontFamily,
  primaryColor: const Color(0xFFFF8200),
  secondaryHeaderColor: const Color(0xFF009f67),
  disabledColor: const Color(0xffa2a7ad),
  brightness: Brightness.dark,
  hintColor: const Color(0xFFbebebe),
  cardColor: const Color(0xFF30313C),
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF8200))), colorScheme: const ColorScheme.dark(primary: Color(0xFFFF8200), secondary: Color(0xFFFF8200)).copyWith(background: const Color(0xFF191A26)).copyWith(error: const Color(0xFFdd3135)),
);
