import 'package:flutter/material.dart';

import '../settings/app_settings_scope.dart';

/// Cadenas mínimas según idioma (es / en) para inicio y ajustes.
/// @author Luis Bermeo
class AppStrings {
  AppStrings._(this._en);

  final bool _en;

  static AppStrings of(BuildContext context) {
    final en = AppSettingsScope.of(context).isEnglish;
    return AppStrings._(en);
  }

  String get homeTitle => _en ? 'My tickets' : 'Mis Tickets';

  String homeSavedCount(int n) =>
      _en ? '$n saved tickets' : '$n tickets guardados';
  String get scanTicket => _en ? 'Scan ticket' : 'Escanear Ticket';
  String get settingsTitle => _en ? 'Settings' : 'Ajustes';
  String get settingsLanguageSection =>
      _en ? 'Language' : 'Idioma de la aplicación';
  String get settingsLanguageHint =>
      _en ? 'Affects labels in home and this screen.' : 'Afecta a textos del inicio y de esta pantalla.';
  String get langSpanish => _en ? 'Spanish' : 'Español';
  String get langEnglish => _en ? 'English' : 'Inglés';
  String get settingsCurrencySection =>
      _en ? 'Currency symbol' : 'Divisa (símbolo)';
  String get settingsCurrencyHint => _en
      ? 'Amounts are not converted; only the symbol shown changes.'
      : 'No se convierten importes; solo cambia el símbolo mostrado.';
  String get settingsAboutSection => _en ? 'About' : 'Acerca de';
  String get settingsAboutBody => _en
      ? 'TickSave — save tickets and warranties. More options will be added later.'
      : 'TickSave — guarda tickets y garantías. Más opciones se añadirán más adelante.';

  String get fillStoreDatePrice => _en
      ? 'Fill store name, date and amount.'
      : 'Rellena comercio, fecha e importe.';
}
