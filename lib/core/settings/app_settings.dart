import 'package:flutter/material.dart';

import 'app_currency.dart';

/// Preferencias globales de la app (idioma, divisa).
///
/// Notifica a los oyentes al cambiar; [TickSaveApp] envuelve [MaterialApp] en un
/// [ListenableBuilder] para aplicar [locale] y reconstruir la UI.
/// @author Javier Abellán
class AppSettingsController extends ChangeNotifier {
  AppSettingsController({
    Locale locale = const Locale('es'),
    AppCurrency currency = AppCurrency.eur,
  })  : _locale = locale,
        _currency = currency;

  Locale _locale;
  AppCurrency _currency;

  Locale get locale => _locale;
  AppCurrency get currency => _currency;
  String get currencySymbol => _currency.symbol;

  bool get isEnglish => _locale.languageCode == 'en';

  void setLocale(Locale value) {
    if (_locale == value) return;
    _locale = value;
    notifyListeners();
  }

  void setCurrency(AppCurrency value) {
    if (_currency == value) return;
    _currency = value;
    notifyListeners();
  }
}
