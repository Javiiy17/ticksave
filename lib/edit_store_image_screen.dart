import 'package:flutter/material.dart';

class EditStoreImageScreen extends StatefulWidget {
  final String storeName;
  final String currentImageUrl;

  const EditStoreImageScreen({
    super.key,
    required this.storeName,
    required this.currentImageUrl,
  });

  @override
  State<EditStoreImageScreen> createState() => _EditStoreImageScreenState();
}

class _EditStoreImageScreenState extends State<EditStoreImageScreen> {
  late TextEditingController _urlController;
  String _previewImageUrl = "";

  // Imágenes de sugerencia (Ejemplos)
  final List<String> _suggestions = [
    "https://images.unsplash.com/photo-1578916171728-46686eac8d58?q=80&w=300&auto=format&fit=crop", // Supermercado genérico 1
    "https://images.unsplash.com/photo-1604719312566-8912e9227c6a?q=80&w=300&auto=format&fit=crop", // Comida sana
    "https://images.unsplash.com/photo-1580913428706-c311ab44351d?q=80&w=300&auto=format&fit=crop", // Pasillo tienda
    "https://images.unsplash.com/photo-1534723452862-4c874018d66d?q=80&w=300&auto=format&fit=crop", // Mercado fresco
  ];

  @override
  void initState() {
    super.initState();
    // Inicializamos con la imagen actual
    _urlController = TextEditingController(text: widget.currentImageUrl);
    _previewImageUrl = widget.currentImageUrl;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _updatePreview(String url) {
    setState(() {
      _previewImageUrl = url;
      _urlController.text = url; // Mantenemos el input sincronizado
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "Editar Imagen de Tienda",
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // --- TARJETA 1: INFO TIENDA ---
            _buildWhiteCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.storeName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Personaliza la imagen de este comercio",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- TARJETA 2: VISTA PREVIA ---
            _buildWhiteCard(
              padding: EdgeInsets.zero, // Sin padding interno para que la imagen llegue al borde
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.network(
                      _previewImageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 180,
                        color: Colors.grey[300],
                        child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text("Vista previa", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- TARJETA 3: URL INPUT ---
            _buildWhiteCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(Icons.image_outlined, "URL de la Imagen", Colors.blue),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _urlController,
                    onChanged: (value) {
                      // Actualizamos la vista previa si el usuario pega una URL
                      if (value.isNotEmpty) {
                        setState(() {
                          _previewImageUrl = value;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "https://ejemplo.com/imagen.jpg",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Pega la URL de una imagen del establecimiento o marca",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- TARJETA 4: SUGERENCIAS ---
            _buildWhiteCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(Icons.search, "Sugerencias", Colors.purple),
                  const SizedBox(height: 16),
                  Text(
                    "Selecciona una de estas imágenes:",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _suggestions.length,
                      separatorBuilder: (c, i) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final url = _suggestions[index];
                        final isSelected = url == _previewImageUrl;
                        return GestureDetector(
                          onTap: () => _updatePreview(url),
                          child: Container(
                            decoration: BoxDecoration(
                              border: isSelected ? Border.all(color: Theme.of(context).primaryColor, width: 3) : null,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(9), // Un poco menos para compensar el borde
                              child: Image.network(
                                url,
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- BOTONES ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                // En edit_store_image_screen.dart
                onPressed: () {
                  // CAMBIO: Pasamos la URL de vuelta en el pop
                  Navigator.pop(context, _urlController.text);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Imagen actualizada correctamente")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1877F2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                child: const Text("Guardar Imagen"),
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
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                child: const Text("Cancelar"),
              ),
            ),

            const SizedBox(height: 30),

            // --- INFO FINAL (TIP AZUL) ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD), // Azul muy clarito
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
                      "Esta imagen se mostrará como encabezado para todos los tickets de ${widget.storeName}",
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES PARA ESTA PANTALLA ---

  // Molde para las tarjetas blancas redondeadas
  Widget _buildWhiteCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  // Encabezado con icono de color
  Widget _buildSectionHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}