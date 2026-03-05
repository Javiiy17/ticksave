import 'package:flutter/material.dart';
import 'login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TickSave',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Color extraído de las imágenes (Azul vibrante)
        primaryColor: const Color(0xFF1A73E8),
        scaffoldBackgroundColor: const Color(0xFF1877F2), // Fondo azul general
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1877F2),
          primary: const Color(0xFF1877F2),
          secondary: const Color(0xFFFFFFFF),
        ),
        useMaterial3: true,
        // Definimos estilo de fuente base (puedes usar Google Fonts más adelante)
        fontFamily: 'Roboto',
      ),
      home: const LoginScreen(),
    );
  }
}