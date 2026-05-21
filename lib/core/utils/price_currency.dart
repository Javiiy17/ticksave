/*
 * ¿Qué hace este archivo?
 * Aquí tenemos unas herramientas para limpiar y formatear los precios.
 * Por ejemplo, si el ticket pone "15,50€", esto le quita el símbolo para 
 * guardarlo limpio en la base de datos, o se lo vuelve a poner para 
 * pintarlo en pantalla.
 */
class DivisaPrecio {
  DivisaPrecio._();

  // Le quita la basurilla al final de los precios (€, $, GBP...)
  static String quitarSufijosConocidos(String precio) {
    var texto = precio.trim();
    while (texto.isNotEmpty) {
      texto = texto.trimRight();
      if (texto.endsWith('€')) {
        texto = texto.substring(0, texto.length - 1);
        continue;
      }
      if (texto.endsWith('\$')) {
        texto = texto.substring(0, texto.length - 1);
        continue;
      }
      if (texto.endsWith('£')) {
        texto = texto.substring(0, texto.length - 1);
        continue;
      }
      final minusculas = texto.toLowerCase();
      if (minusculas.endsWith('eur')) {
        texto = texto.substring(0, texto.length - 3);
        continue;
      }
      if (minusculas.endsWith('usd')) {
        texto = texto.substring(0, texto.length - 3);
        continue;
      }
      if (minusculas.endsWith('gbp')) {
        texto = texto.substring(0, texto.length - 3);
        continue;
      }
      break;
    }
    return texto.trim();
  }

  // Le pega el símbolo de la moneda al final del número
  static String conSimbolo(String entradaImporte, String simbolo) {
    final base = quitarSufijosConocidos(entradaImporte);
    return '$base $simbolo';
  }

  // Lo formatea bonito para enseñarlo en pantalla, pero si ve que no es un número
  // (por ejemplo si el OCR ha leído "Cebollas"), lo devuelve tal cual para no romper nada.
  static String formatearParaVista(String guardado, String simbolo) {
    final recortado = guardado.trim();
    final limpio = quitarSufijosConocidos(recortado);
    if (limpio == recortado && !RegExp(r'\d').hasMatch(recortado)) {
      return guardado;
    }
    return '$limpio $simbolo';
  }
}
