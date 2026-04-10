/// URLs seguras para [Image.network] / [NetworkImage] en Flutter.
///
/// - Una cadena vacía dispara un `assert` en el framework.
/// - Los SVG no se decodifican como imágenes ráster y suelen romper la carga.
String rasterHttpUrlOrPlaceholder(String url) {
  const placeholder =
      'https://images.unsplash.com/photo-1578916171728-46686eac8d58?q=80&w=1000&auto=format&fit=crop';
  final trimmed = url.trim();
  if (trimmed.isEmpty) return placeholder;
  final uri = Uri.tryParse(trimmed);
  if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
    return placeholder;
  }
  if (uri.path.toLowerCase().endsWith('.svg')) return placeholder;
  return trimmed;
}
