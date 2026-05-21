/*
 * Evita que las imágenes que cargamos de internet revienten la app.
 * Las URL a veces están vacías o son archivos .svg.
 * Si vemos algo raro, devolvemos la URL de una foto de archivo genérica.
 */
String urlRasterHttpOPlaceholder(String url) {
  const fotoDeRelleno =
      'https://images.unsplash.com/photo-1578916171728-46686eac8d58?q=80&w=1000&auto=format&fit=crop';
  final urlLimpia = url.trim();
  if (urlLimpia.isEmpty) return fotoDeRelleno;
  
  final uri = Uri.tryParse(urlLimpia);
  if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
    return fotoDeRelleno;
  }
  
  if (uri.path.toLowerCase().endsWith('.svg')) return fotoDeRelleno;
  return urlLimpia;
}
