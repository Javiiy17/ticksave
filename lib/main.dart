import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'core/settings/app_settings.dart';
import 'core/settings/app_settings_scope.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'firebase_options.dart';

/*
 * Este es el corazón de la app, lo primero que se ejecuta al abrirla.
 * Arrancamos la base de datos de Firebase y lanzamos la primera pantalla.
 * 
 * @author Javier Abellán y Luis Bermeo
 */
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Carga lo básico de Flutter
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Conecta con Google
  );
  runApp(AppTickSave(ajustes: ControladorAjustesApp()));
}

/*
 * Cascarón de la app. Le decimos que use nuestro tema de colores oscuro,
 * que esconda la etiquetita de "DEBUG" de la esquina, y que empiece mirando a ver 
 * si el usuario ya había metido su correo antes o si le pedimos login.
 */
class AppTickSave extends StatelessWidget {
  const AppTickSave({super.key, required this.ajustes});

  final ControladorAjustesApp ajustes;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ajustes,
      builder: (context, _) {
        return AlcanceAjustesApp(
          notifier: ajustes,
          child: MaterialApp(
            title: 'TickSave',
            debugShowCheckedModeBanner: false, // Fuera la banda roja fea de debug
            theme: temaApp,
            locale: ajustes.idioma,
            supportedLocales: const [
              Locale('es'),
              Locale('en'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const PuertaAutenticacion(),
          ),
        );
      },
    );
  }
}

// Mira si tienes sesión iniciada o no.
class PuertaAutenticacion extends StatelessWidget {
  const PuertaAutenticacion({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, instantanea) {
        if (instantanea.connectionState == ConnectionState.waiting) {
          // Mientras cargamos, ponemos una ruedita rosa dando vueltas
          return const Scaffold(
            backgroundColor: Color(0xFF090310),
            body: Center(child: CircularProgressIndicator(color: Color(0xFFE91E63))),
          );
        }
        // Si el usuario ya está logueado, a PantallaInicio
        if (instantanea.hasData) {
          return const PantallaInicio();
        }
        // Si no está logueado, a PantallaLogin
        return const PantallaLogin();
      },
    );
  }
}
