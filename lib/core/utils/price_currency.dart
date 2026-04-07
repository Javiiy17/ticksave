/// Utilidades para quitar / aplicar símbolos de divisa en textos de importe.
class PriceCurrency {
  PriceCurrency._();

  /// Quita sufijos habituales (€, \$, £, EUR, USD, GBP).
  static String stripKnownSuffixes(String price) {
    var t = price.trim();
    while (t.isNotEmpty) {
      t = t.trimRight();
      if (t.endsWith('€')) {
        t = t.substring(0, t.length - 1);
        continue;
      }
      if (t.endsWith('\$')) {
        t = t.substring(0, t.length - 1);
        continue;
      }
      if (t.endsWith('£')) {
        t = t.substring(0, t.length - 1);
        continue;
      }
      final low = t.toLowerCase();
      if (low.endsWith('eur')) {
        t = t.substring(0, t.length - 3);
        continue;
      }
      if (low.endsWith('usd')) {
        t = t.substring(0, t.length - 3);
        continue;
      }
      if (low.endsWith('gbp')) {
        t = t.substring(0, t.length - 3);
        continue;
      }
      break;
    }
    return t.trim();
  }

  /// Montante + símbolo elegido (p. ej. guardar tras editar).
  static String withSymbol(String amountInput, String symbol) {
    final base = stripKnownSuffixes(amountInput);
    return '$base $symbol';
  }

  /// Texto para listas y detalle: si no parece un importe numérico, se devuelve tal cual.
  static String formatForDisplay(String stored, String symbol) {
    final trimmed = stored.trim();
    final stripped = stripKnownSuffixes(trimmed);
    if (stripped == trimmed && !RegExp(r'\d').hasMatch(trimmed)) {
      return stored;
    }
    return '$stripped $symbol';
  }
}
