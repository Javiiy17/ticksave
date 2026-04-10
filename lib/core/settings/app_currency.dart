/// Divisas disponibles en ajustes (solo símbolo de visualización; sin conversión de tipo de cambio).
enum AppCurrency {
  eur,
  usd,
  gbp,
}

extension AppCurrencyX on AppCurrency {
  String get symbol => switch (this) {
        AppCurrency.eur => '€',
        AppCurrency.usd => r'$',
        AppCurrency.gbp => '£',
      };

  String get code => switch (this) {
        AppCurrency.eur => 'EUR',
        AppCurrency.usd => 'USD',
        AppCurrency.gbp => 'GBP',
      };

  String get labelEs => switch (this) {
        AppCurrency.eur => 'Euro (EUR, €)',
        AppCurrency.usd => 'Dólar (USD, \$)',
        AppCurrency.gbp => 'Libra (GBP, £)',
      };

  String get labelEn => switch (this) {
        AppCurrency.eur => 'Euro (EUR, €)',
        AppCurrency.usd => 'US dollar (USD, \$)',
        AppCurrency.gbp => 'Pound (GBP, £)',
      };
}
