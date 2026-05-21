/*
 * ¿Qué hace este archivo?
 * Aquí tenemos la lista de monedas que se pueden usar en la app.
 * De momento solo cambia el dibujito (€, $...) para que quede bonito, 
 * no hace cálculos matemáticos de cambio de divisa reales.
 */
enum MonedaApp {
  eur,
  usd,
  gbp,
}

extension ExtensionMonedaApp on MonedaApp {
  // El dibujito que sale al lado del precio
  String get simbolo => switch (this) {
        MonedaApp.eur => '€',
        MonedaApp.usd => r'$',
        MonedaApp.gbp => '£',
      };

  // Las siglas para los bancos
  String get codigo => switch (this) {
        MonedaApp.eur => 'EUR',
        MonedaApp.usd => 'USD',
        MonedaApp.gbp => 'GBP',
      };

  // El texto que sale en los ajustes cuando la app está en español
  String get etiquetaEs => switch (this) {
        MonedaApp.eur => 'Euro (EUR, €)',
        MonedaApp.usd => 'Dólar (USD, \$)',
        MonedaApp.gbp => 'Libra (GBP, £)',
      };

  // El texto que sale en los ajustes cuando la app está en inglés
  String get etiquetaEn => switch (this) {
        MonedaApp.eur => 'Euro (EUR, €)',
        MonedaApp.usd => 'US dollar (USD, \$)',
        MonedaApp.gbp => 'Pound (GBP, £)',
      };
}
