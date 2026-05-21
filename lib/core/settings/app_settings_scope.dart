import 'package:flutter/material.dart';

import 'app_settings.dart';

/*
 * ¿Qué hace este archivo?
 * Hace que cualquier pantalla 
 * pueda acceder a los ajustes del usuario súper rápido y sin tener que pasar 
 * variables de un lado a otro.
 */
class AlcanceAjustesApp extends InheritedNotifier<ControladorAjustesApp> {
  const AlcanceAjustesApp({
    super.key,
    required ControladorAjustesApp super.notifier,
    required super.child,
  });

  // Pillamos los ajustes desde cualquier parte de la app
  static ControladorAjustesApp of(BuildContext context) {
    final alcance =
        context.dependOnInheritedWidgetOfExactType<AlcanceAjustesApp>();
    assert(
      alcance != null, 
      'No hemos encontrado los Ajustes en esta pantalla, algo ha petado'
    );
    return alcance!.notifier!;
  }
}
