import 'package:flutter/material.dart';

import '../../../core/utils/raster_image_url.dart';

/// Pantalla que permite personalizar la imagen asociada a una tienda.
///
/// El flujo es:
/// - Se muestra la imagen actual y una vista previa.
/// - El usuario puede pegar una URL o elegir una sugerencia.
/// - Al guardar, devolvemos la URL seleccionada con `Navigator.pop`.
class EditStoreImageScreen extends StatefulWidget {
  const EditStoreImageScreen({
    super.key,
    required this.storeName,
    required this.currentImageUrl,
  });

  final String storeName;
  final String currentImageUrl;

  @override
  State<EditStoreImageScreen> createState() => _EditStoreImageScreenState();
}

class _EditStoreImageScreenState extends State<EditStoreImageScreen> {
  late final TextEditingController _urlController;
  late String _previewImageUrl;

  /// Sugerencias de imagen para que el usuario pueda elegir rápido
  /// sin tener que buscar una URL.
  final List<String> _suggestions = [
    'https://images.unsplash.com/photo-1578916171728-46686eac8d58?q=80&w=300&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?q=80&w=300&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1534723452862-4c874018d66d?q=80&w=300&auto=format&fit=crop',
  ];

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.currentImageUrl);
    _previewImageUrl = widget.currentImageUrl.trim();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _updatePreview(String url) {
    setState(() {
      _previewImageUrl = url;
      _urlController.text = url;
    });
  }

  void _saveImage() {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context, _urlController.text);
    messenger.showSnackBar(
      const SnackBar(content: Text('Imagen actualizada correctamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Editar Imagen de Tienda',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildStoreInfoCard(),
            const SizedBox(height: 20),
            _buildPreviewCard(),
            const SizedBox(height: 20),
            _buildUrlInputCard(),
            const SizedBox(height: 20),
            _buildSuggestionsCard(),
            const SizedBox(height: 30),
            _buildActions(),
            const SizedBox(height: 30),
            _buildHintCard(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreInfoCard() {
    return _buildWhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.storeName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Personaliza la imagen de este comercio',
            style: const TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    return _buildWhiteCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(
              rasterHttpUrlOrPlaceholder(_previewImageUrl),
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Vista previa',
              style: const TextStyle(color: Colors.black, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlInputCard() {
    return _buildWhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            Icons.image_outlined,
            'URL de la imagen',
            Colors.blue,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _urlController,
            onChanged: (value) {
              if (value.isNotEmpty) {
                setState(() {
                  _previewImageUrl = value;
                });
              }
            },
            decoration: InputDecoration(
              hintText: 'https://ejemplo.com/imagen.jpg',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pega la URL de una imagen del establecimiento o marca',
            style: const TextStyle(color: Colors.black, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsCard() {
    return _buildWhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            Icons.search,
            'Sugerencias',
            Colors.purple,
          ),
          const SizedBox(height: 16),
          Text(
            'Selecciona una de estas imágenes:',
            style: const TextStyle(color: Colors.black),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _suggestions.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final url = _suggestions[index];
                final isSelected = url == _previewImageUrl;
                return GestureDetector(
                  onTap: () => _updatePreview(url),
                  child: Container(
                    decoration: BoxDecoration(
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 3,
                            )
                          : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: Image.network(
                        rasterHttpUrlOrPlaceholder(url),
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => ColoredBox(
                          color: Colors.grey[300]!,
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _saveImage,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1877F2),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            child: const Text('Guardar imagen'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black87,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.white,
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            child: const Text('Cancelar'),
          ),
        ),
      ],
    );
  }

  Widget _buildHintCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBBDEFB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: Colors.orange, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Esta imagen se mostrará como encabezado para todos los tickets de ${widget.storeName}.',
              style: TextStyle(
                color: Colors.blue[800],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Plantilla de tarjeta blanca reutilizada en esta pantalla.
  Widget _buildWhiteCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  /// Encabezado de sección con icono de color.
  Widget _buildSectionHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

