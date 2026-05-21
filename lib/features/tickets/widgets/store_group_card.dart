import 'package:flutter/material.dart';
import '../../../core/utils/raster_image_url.dart';
import '../../tickets/models/ticket.dart';
import '../screens/store_tickets_screen.dart';
import '../../../core/l10n/app_strings.dart';

/*
 * ¿Qué hace este archivo?
 * Aquí creamos una "Tarjeta" visual súper chula que agrupa todos los tickets 
 * de una misma tienda. Así, en vez de ver 50 tickets sueltos de Mercadona, 
 * ves una sola cajita de "Mercadona" con el total de lo que te has gastado.
 */
class TarjetaGrupoComercio extends StatelessWidget {
  const TarjetaGrupoComercio({
    super.key,
    required this.nombreComercio,
    required this.tickets,
  });

  final String nombreComercio;
  final List<Ticket> tickets;

  @override
  Widget build(BuildContext context) {
    // Vamos sumando lo que cuesta cada ticket para sacar el total gastado en esta tienda
    double totalGastado = 0.0;
    for (var ticket in tickets) {
      // Limpiamos la basurilla del string (símbolos raros) para quedarnos solo con el número
      final precioLimpio = ticket.precio.replaceAll(RegExp(r'[^0-9.,]'), '').replaceAll(',', '.');
      final valorNumerico = double.tryParse(precioLimpio);
      if (valorNumerico != null) totalGastado += valorNumerico;
    }

    // Pillamos la imagen del primer ticket que tenga una, para ponerla de fondo de la tarjeta y que quede bonito
    final String imagenFondo = tickets.firstWhere(
      (ticket) => ticket.urlImagen.isNotEmpty, 
      orElse: () => tickets.first
    ).urlImagen;

    // Esto nos asegura que si la URL está rota no nos explote la app
    final urlSegura = urlRasterHttpOPlaceholder(imagenFondo);

    return GestureDetector(
      onTap: () {
        // Al tocar la tarjeta, nos vamos a otra pantalla para ver los tickets de esta tienda en detalle
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PantallaTicketsComercio( // Nota: la pantalla PantallaTicketsComercio la traduciré luego
              nombreComercio: nombreComercio,
              tickets: tickets,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: ShaderMask(
                    shaderCallback: (rectangulo) {
                      return const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black54, Colors.transparent],
                      ).createShader(rectangulo);
                    },
                    blendMode: BlendMode.darken,
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(urlSegura),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.folder, color: Colors.white, size: 28),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          nombreComercio,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis, // Si el nombre es larguísimo, ponemos "..."
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.receipt_long, color: Colors.grey, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '${tickets.length} ${TextosApp.de(context).recibosX}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${totalGastado.toStringAsFixed(2)} €',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
