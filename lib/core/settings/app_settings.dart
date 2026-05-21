import 'package:flutter/material.dart';

import 'app_currency.dart';

/*
 * ¿Qué hace este archivo?
 * Aquí guardamos las preferencias del usuario para toda la app (como el idioma 
 * o si usa Euros o Dólares). Cuando cambia algo, esto avisa a todas las pantallas 
 * para que se repinten y se actualicen al instante.
 */
class ControladorAjustesApp extends ChangeNotifier {
  ControladorAjustesApp({
    Locale idioma = const Locale('es'),
    MonedaApp moneda = MonedaApp.eur,
  })  : _idioma = idioma,
        _moneda = moneda;

  Locale _idioma;
  MonedaApp _moneda;

  Locale get idioma => _idioma;
  MonedaApp get moneda => _moneda;
  String get simboloMoneda => _moneda.simbolo;

  // Un atajo rápido para saber si el usuario lo tiene puesto en inglés
  bool get esIngles => _idioma.languageCode == 'en';

  void cambiarIdioma(Locale nuevoIdioma) {
    if (_idioma == nuevoIdioma) return; // Si es el mismo ni nos molestamos
    _idioma = nuevoIdioma;
    notifyListeners(); // ¡Eh, que hemos cambiado el idioma, que se actualice todo!
  }

  void cambiarMoneda(MonedaApp nuevaMoneda) {
    if (_moneda == nuevaMoneda) return;
    _moneda = nuevaMoneda;
    notifyListeners();
  }
}
