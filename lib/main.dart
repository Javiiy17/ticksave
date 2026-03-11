import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'firebase_options.dart';

/// Punto de entrada de la aplicación.
///
/// Aquí inicializamos Firebase antes de montar el árbol de widgets.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TickSave',
      debugShowCheckedModeBanner: false,
      // Extraemos el tema a un archivo separado para mantener `main.dart` sencillo.
      theme: appTheme,
      home: const LoginScreen(),
    );
  }
}