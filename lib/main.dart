import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/settings/app_settings.dart';
import 'core/settings/app_settings_scope.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'firebase_options.dart';

/// Punto de entrada de la aplicación.
///
/// Aquí inicializamos Firebase antes de montar el árbol de widgets.
/// @author Javier Abellán
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(TickSaveApp(settings: AppSettingsController()));
}

/// Widget raíz de la aplicación que administra el flujo del estado y la configuración general.
/// @author Javier Abellán
class TickSaveApp extends StatelessWidget {
  const TickSaveApp({super.key, required this.settings});

  final AppSettingsController settings;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return AppSettingsScope(
          notifier: settings,
          child: MaterialApp(
            title: 'TickSave',
            debugShowCheckedModeBanner: false,
            theme: appTheme,
            locale: settings.locale,
            supportedLocales: const [
              Locale('es'),
              Locale('en'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const LoginScreen(),
          ),
        );
      },
    );
  }
}
