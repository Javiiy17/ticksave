import 'package:flutter/material.dart';

import '../../../core/utils/raster_image_url.dart';

/*
 * ¿Qué hace este archivo?
 * Como a veces la IA no encuentra un buen logo para una tienda 
 * (imagina "Zapatería Paco"), esta pantalla te deja poner un enlace de Google 
 * a la imagen que tú quieras para la carpeta de esa tienda. 
 * Te damos 3 fotos de stock predeterminadas por si pasas de buscar enlaces.
 */
class PantallaEditarImagenComercio extends StatefulWidget {
  const PantallaEditarImagenComercio({
    super.key,
    required this.nombreComercio,
    required this.currentImageUrl,
  });

  final String nombreComercio;
  final String currentImageUrl;

  @override
  State<PantallaEditarImagenComercio> createState() => _EstadoPantallaEditarImagenComercio();
}

class _EstadoPantallaEditarImagenComercio extends State<PantallaEditarImagenComercio> {
  late final TextEditingController _controladorUrl;
  late String _urlImagenPrevia;

  // Unas cuantas fotos random muy aesthetics de Unsplash para salir del paso
  final List<String> _sugerencias = [
    'https://images.unsplash.com/photo-1578916171728-46686eac8d58?q=80&w=300&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?q=80&w=300&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1534723452862-4c874018d66d?q=80&w=300&auto=format&fit=crop',
  ];

  @override
  void initState() {
    super.initState();
    _controladorUrl = TextEditingController(text: widget.currentImageUrl);
    _urlImagenPrevia = widget.currentImageUrl.trim();
  }

  @override
  void dispose() {
    _controladorUrl.dispose();
    super.dispose();
  }

  // Refresca la pantallita de arriba cuando metes una URL nueva
  void _actualizarVistaPrevia(String url) {
    setState(() {
      _urlImagenPrevia = url;
      _controladorUrl.text = url;
    });
  }

  // Devolvemos el texto de la URL a la pantalla anterior
  void _guardarImagen() {
    final mensajero = ScaffoldMessenger.of(context);
    Navigator.pop(context, _controladorUrl.text);
    mensajero.showSnackBar(
      const SnackBar(
        content: Text('Imagen actualizada correctamente', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
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
            _construirTarjetaInfoTienda(),
            const SizedBox(height: 20),
            _construirTarjetaVistaPrevia(),
            const SizedBox(height: 20),
            _construirTarjetaCajaUrl(),
            const SizedBox(height: 20),
            _construirTarjetaSugerencias(),
            const SizedBox(height: 30),
            _construirBotones(),
            const SizedBox(height: 30),
            _construirTarjetaPista(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _construirTarjetaInfoTienda() {
    return _construirTarjetaBlanca(
      hijo: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.nombreComercio,
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

  // Pinta la imagen de cómo va a quedar en grande
  Widget _construirTarjetaVistaPrevia() {
    return _construirTarjetaBlanca(
      relleno: EdgeInsets.zero,
      hijo: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(
              urlRasterHttpOPlaceholder(_urlImagenPrevia),
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              // Si la URL que meten está rota, ponemos un cuadrao gris chusquero
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

  // La caja de texto gigante para que el usuario pegue lo del portapapeles
  Widget _construirTarjetaCajaUrl() {
    return _construirTarjetaBlanca(
      hijo: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _construirCabeceraSeccion(
            Icons.image_outlined,
            'URL de la imagen',
            Colors.blue,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controladorUrl,
            onChanged: (valor) {
              if (valor.isNotEmpty) {
                setState(() {
                  _urlImagenPrevia = valor;
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

  // Tres fotitos en horizontal para la gente vaga
  Widget _construirTarjetaSugerencias() {
    return _construirTarjetaBlanca(
      hijo: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _construirCabeceraSeccion(
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
              itemCount: _sugerencias.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final url = _sugerencias[index];
                final estaSeleccionada = url == _urlImagenPrevia;
                return GestureDetector(
                  onTap: () => _actualizarVistaPrevia(url),
                  child: Container(
                    decoration: BoxDecoration(
                      // Borde gordito si está seleccionada
                      border: estaSeleccionada
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
                        urlRasterHttpOPlaceholder(url),
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

  // Guardar o a la verga
  Widget _construirBotones() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _guardarImagen,
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

  // Cajita azul explicativa abajo del todo
  Widget _construirTarjetaPista() {
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
              'Esta imagen se mostrará como encabezado para todos los tickets de ${widget.nombreComercio}.',
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

  // Código reutilizable para que todo tenga el mismo fondo blanco redondito con sombra 
  Widget _construirTarjetaBlanca({required Widget hijo, EdgeInsetsGeometry? relleno}) {
    return Container(
      width: double.infinity,
      padding: relleno ?? const EdgeInsets.all(20),
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
      child: hijo,
    );
  }

  // Título de la tarjeta con su iconito mono al lado
  Widget _construirCabeceraSeccion(IconData icono, String titulo, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icono, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          titulo,
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
