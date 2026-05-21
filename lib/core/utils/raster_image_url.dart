/*
 * ¿Qué hace este archivo?
 * Una movida técnica para que las imágenes que cargamos de internet no revienten la app.
 * A veces las URL están vacías o son archivos .svg (que a Flutter no le molan mucho).
 * Si vemos algo raro, devolvemos la URL de una foto de archivo genérica para salir del paso.
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
