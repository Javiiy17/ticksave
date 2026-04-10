import 'package:flutter/material.dart';

/// Tema global de la aplicación TickSave.
///
/// Objetivos del diseño (Dopamina Visual):
/// - **Material 3** activado.
/// - **Modo oscuro profundo** como base (Dark Purple).
/// - **Acento Rosa y Púrpura** para elementos interactivos.
/// - Tarjetas y controles con **bordes ultra redondeados (25.0)** y estilo premium.
final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  // Tipografía potente (intentará usar la del sistema, pero bien ajustada)
  fontFamily: 'Inter', // Usaremos Inter si está o fallará amigablemente al default
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFE91E63), // Pink
    primary: const Color(0xFFFF4081), // Pink Accent
    secondary: const Color(0xFF9C27B0), // Purple
    brightness: Brightness.dark,
    surface: const Color(0xFF0D0518), // Deep purple/black
  ),
  scaffoldBackgroundColor: const Color(0xFF090310),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent, // Background transparente para degradados
    elevation: 0,
    centerTitle: true,
    foregroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFF140A26), // Ligeramente más claro que el fondo
    elevation: 4,
    shadowColor: const Color(0xFFFF4081).withValues(alpha: 0.2), // Sombra suave rosada
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25.0),
    ),
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent, // Lo manejaremos con Ink y gradientes en la UI
      shadowColor: Colors.transparent,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      textStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        letterSpacing: 1.2,
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: const Color(0xFFFF4081).withValues(alpha: 0.5), width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      foregroundColor: Colors.white,
      textStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFFFF4081),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1A0B2E).withValues(alpha: 0.6), // Transparencia premium
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25.0),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25.0),
      borderSide: const BorderSide(color: Color(0xFFFF4081), width: 2.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25.0),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1.0),
    ),
    hintStyle: TextStyle(
      color: Colors.white.withValues(alpha: 0.3),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Color(0xFF1A0B2E),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(25.0)),
    ),
  ),
);
