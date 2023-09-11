import 'package:flutter/material.dart';

ThemeData dark = ThemeData(
  fontFamily: 'Roboto',
  primaryColor: const Color(0xFFd7263d),
  secondaryHeaderColor: const Color(0xFFd7263d),
  disabledColor: const Color(0xFF6f7275),
  brightness: Brightness.dark,
  hintColor: const Color(0xFFbebebe),
  cardColor: Colors.black,
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: const Color(0xFFd7263d))), colorScheme: const ColorScheme.dark(primary: Color(0xFFd7263d), secondary: Color(0xFFd7263d)).copyWith(error: const Color(0xFFdd3135)),
);
