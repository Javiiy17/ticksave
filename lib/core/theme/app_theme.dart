import 'package:flutter/material.dart';

/// Tema global de la aplicación TickSave.
///
/// Objetivos del diseño:
/// - **Material 3** activado.
/// - **Modo oscuro profundo** como base.
/// - **Acento cyan** para elementos interactivos.
/// - Tarjetas y controles con **bordes redondeados** y estilo minimalista.
final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  fontFamily: 'Roboto',
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF00BCD4), // cyan
    brightness: Brightness.dark,
  ),
  scaffoldBackgroundColor: const Color(0xFF050816),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF050816),
    elevation: 0,
    centerTitle: true,
    foregroundColor: Colors.white,
  ),
  // A partir de versiones recientes de Flutter, `cardTheme` usa `CardThemeData`.
  cardTheme: CardThemeData(
    color: const Color(0xFF0B1020),
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    margin: const EdgeInsets.all(8),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF00BCD4),
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      textStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      foregroundColor: Colors.white,
      textStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF111827),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFF00BCD4), width: 1.5),
    ),
    hintStyle: TextStyle(
      color: Colors.white.withValues(alpha: 0.4),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Color(0xFF111827),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),
);

