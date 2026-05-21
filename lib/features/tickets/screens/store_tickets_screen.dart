import 'package:flutter/material.dart';
import '../../tickets/models/ticket.dart';
import '../widgets/ticket_store_card.dart';
import 'edit_store_image_screen.dart';
import '../../tickets/services/ticket_service.dart';
import '../../../core/l10n/app_strings.dart';

/*
 * ¿Qué hace este archivo?
 * Cuando pinchas en la carpeta de un comercio (por ejemplo, "Zara"), te trae a esta pantalla.
 * Aquí mostramos una lista hacia abajo con todos los tickets que tienes de ese comercio.
 * Es como abrir un cajón y ver todo lo que has comprado ahí.
 */
class PantallaTicketsComercio extends StatefulWidget {
  final String nombreComercio;
  final List<Ticket> tickets;

  const PantallaTicketsComercio({
    super.key,
    required this.nombreComercio,
    required this.tickets,
  });

  @override
  State<PantallaTicketsComercio> createState() => _EstadoPantallaTicketsComercio();
}

class _EstadoPantallaTicketsComercio extends State<PantallaTicketsComercio> {
  final ServicioTicket _servicioTicket = ServicioTicket();
  late List<Ticket> _ticketsLocales;

  @override
  void initState() {
    super.initState();
    // Nos hacemos una copia local para poder borrarlos o modificarlos de la lista al vuelo
    _ticketsLocales = List.from(widget.tickets);
    // Ordenamos todo de más nuevo a más viejo para que el último gasto salga el primero
    _ticketsLocales.sort((a, b) => b.fechaCompra.compareTo(a.fechaCompra));
  }

  // Te lleva a otra pantalla para cambiarle la foto genérica a la carpeta de la tienda
  void _abrirEditarImagenComercio(Ticket ticketActual) async {
    final nuevaUrl = await Navigator.push<String?>(
      context,
      MaterialPageRoute<String?>(
        builder: (context) => PantallaEditarImagenComercio( // La traducimos luego
          nombreComercio: ticketActual.nombreComercio,
          currentImageUrl: ticketActual.urlImagen,
        ),
      ),
    );

    if (nuevaUrl == null || nuevaUrl.isEmpty) return;

    ticketActual.urlImagen = nuevaUrl;
    await _servicioTicket.actualizarTicket(ticketActual);
    setState(() {});
  }

  // Si nos hemos cansado de esta tienda, nos cargamos la carpeta entera con todos sus tickets
  Future<void> _eliminarCarpeta() async {
    final textos = TextosApp.de(context);
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF140A26),
        title: Text(textos.tituloConfirmarEliminarCarpeta, style: const TextStyle(color: Colors.white)),
        content: Text(textos.cuerpoConfirmarEliminarCarpeta, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(textos.cancelar, style: const TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: Text(textos.borrar, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmacion == true) {
      // Arrasamos con todos los tickets de esta tienda en la base de datos
      for (final ticket in widget.tickets) {
        if (ticket.id != null) {
          await _servicioTicket.eliminarTicket(ticket.id!);
        }
      }
      if (mounted) Navigator.pop(context); // Y volvemos al Home
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Tonito claro para que parezca de día
      appBar: AppBar(
        title: Text(TextosApp.de(context).tituloTicketsComercio(widget.nombreComercio)),
        backgroundColor: const Color(0xFF090310),
        foregroundColor: Colors.white,
        actions: [
          // Botón de la papelera arriba a la derecha, bien escondidito para no darle sin querer
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
            onPressed: _eliminarCarpeta,
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _ticketsLocales.length,
        separatorBuilder: (context, indice) => const SizedBox(height: 20),
        itemBuilder: (context, indice) {
          final ticket = _ticketsLocales[indice];
          // Pintamos cada ticket con su tarjeta
          return TarjetaComercioTicket(
            ticket: ticket,
            alPulsarEditar: () => _abrirEditarImagenComercio(ticket),
            alEliminar: () {
              // Si han borrado el ticket por ahí dentro, lo quitamos de esta lista también
              setState(() {
                _ticketsLocales.removeWhere((item) => item.id == ticket.id);
              });
            },
          );
        },
      ),
    );
  }
}
