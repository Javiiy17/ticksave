import 'package:flutter/material.dart';

import '../../../core/utils/raster_image_url.dart';
import '../models/ticket.dart';
import '../screens/ticket_detail_screen.dart';

/*
 * Esta es la tarjetita individual de cada ticket. 
 * Tiene un diseño limpio para que el usuario pueda ver rápido 
 * lo que compró, cuándo y cuánto costó. Y si está a punto de caducar
 * la garantía, ¡le pone el borde rojo para avisar!
 */
class TarjetaComercioTicket extends StatelessWidget {
  const TarjetaComercioTicket({
    super.key,
    required this.ticket,
    required this.alPulsarEditar,
    this.alEliminar,
  });

  final Ticket ticket;
  final VoidCallback alPulsarEditar;
  final VoidCallback? alEliminar;

  @override
  Widget build(BuildContext context) {
    // Comprobamos si la garantía de este ticket está en las últimas
    final bool caducaPronto = ticket.estaApuntoDeCaducar;
    
    return GestureDetector(
      onTap: () async {
        // Al tocar el ticket nos vamos a ver todos los detalles (foto en grande, etc)
        final resultado = await Navigator.push<bool>(
          context,
          MaterialPageRoute<bool>(
            builder: (context) => PantallaDetalleTicket(ticket: ticket), // Lo traduciremos luego
          ),
        );
        // Si venimos de vuelta y el ticket se ha borrado en la otra pantalla, avisamos para refrescar
        if (resultado == true && alEliminar != null) {
          alEliminar!();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          // Borde rojito de advertencia si la garantía vuela
          border: caducaPronto ? Border.all(color: Colors.redAccent, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: caducaPronto ? Colors.redAccent.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            _construirImagenCabecera(context),
            _construirFilaInfoTicket(context, caducaPronto),
          ],
        ),
      ),
    );
  }

  // Montamos la foto del ticket arriba del todo con un degradado negro para que se lean las letras blancas
  Widget _construirImagenCabecera(BuildContext context) {
    final urlSegura = urlRasterHttpOPlaceholder(ticket.urlImagen);
    return Stack(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ticket.nombreComercio,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                ),
              ),
              // El botoncito de editar (el lapiz chiquito)
              Material(
                color: Colors.white,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: alPulsarEditar,
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // La zona de abajo de la tarjeta donde ponemos la pasta, la fecha y la garantía
  Widget _construirFilaInfoTicket(BuildContext context, bool caducaPronto) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      ticket.precio,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ticket.fechaFormateada,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Si quedan menos de 30 días, sacamos este cartelito rojo
          if (caducaPronto)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: const [
                  Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Caduca < 30 días',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
