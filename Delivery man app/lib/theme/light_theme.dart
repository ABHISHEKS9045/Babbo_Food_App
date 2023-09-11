import 'package:flutter/material.dart';

ThemeData light = ThemeData(
  fontFamily: 'Roboto',
  primaryColor: const Color(0xFFd7263d),
  secondaryHeaderColor: const Color(0xFFd7263d),
  disabledColor: const Color(0xFFA0A4A8),
  brightness: Brightness.light,
  hintColor: const Color(0xFF9F9F9F),
  cardColor: Colors.white,
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: const Color(0xFFd7263d))), colorScheme: const ColorScheme.light(primary: Color(0xFFd7263d), secondary: Color(0xFFd7263d)).copyWith(error: const Color(0xFFd7263d)),
);