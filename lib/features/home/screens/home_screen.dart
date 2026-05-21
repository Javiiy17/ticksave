import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../tickets/models/ticket.dart';
import '../../tickets/screens/scan_ticket_screen.dart';
import '../../tickets/screens/barcode_scanner_screen.dart';
import '../../tickets/services/ticket_service.dart';
import '../../tickets/widgets/store_group_card.dart';
import '../../settings/screens/settings_screen.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/screens/login_screen.dart';
import '../widgets/header_icon.dart';

/*
 * ¿Qué hace este archivo?
 * Esta es la pantalla principal, el "Home" donde aterrizas al entrar en la app.
 * Te enseña todas las carpetitas de tus tiendas y te deja buscar tickets.
 * También tiene el botón tocho rosa abajo para escanear tickets nuevos.
 */
class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _EstadoPantallaInicio();
}

class _EstadoPantallaInicio extends State<PantallaInicio> {
  final ServicioTicket _servicioTicket = ServicioTicket();
  String _consultaBusqueda = "";

  // Despliega una ventanita por abajo para que elijas si quieres escanear con la cámara 
  // para leer el texto (OCR) o si prefieres leer el código de barras del súper.
  void _irAPantallaEscaner() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        final textos = TextosApp.de(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  textos.elegirModoEscaneo,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.document_scanner, color: Color(0xFFE91E63)),
                  title: Text(textos.tituloEscanearOcr),
                  subtitle: Text(textos.subtituloEscanearOcr),
                  onTap: () {
                    Navigator.pop(context); // Escondemos el menú
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PantallaEscanearTicket()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.qr_code_scanner, color: Color(0xFFE91E63)),
                  title: Text(textos.tituloEscanearBarras),
                  subtitle: Text(textos.subtituloEscanearBarras),
                  onTap: () {
                    Navigator.pop(context); // Escondemos el menú
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PantallaEscanerCodigo()),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _construirCabecera(context),
            Expanded(child: _construirListaTickets(context)),
          ],
        ),
      ),
    );
  }

  // La parte de arriba moradita oscura con el buscador, la tuerca de ajustes y la puerta de salir
  Widget _construirCabecera(BuildContext context) {
    final textos = TextosApp.de(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    textos.tituloInicio,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconoCabecera(
                    icono: Icons.settings_outlined,
                    alPulsar: () {
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const PantallaAjustes(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  IconoCabecera(
                    icono: Icons.logout,
                    alPulsar: () async {
                      // Nos deslogueamos de Firebase y pa' la calle
                      await ServicioAutenticacion().cerrarSesion();
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const PantallaLogin()),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Buscador en tiempo real
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: textos.buscarComercio,
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
            ),
            onChanged: (valor) {
              setState(() {
                // Lo pasamos todo a minúsculas pa que no haya líos al buscar "Zara" o "zara"
                _consultaBusqueda = valor.toLowerCase();
              });
            },
          )
        ],
      ),
    );
  }

  // Zona blanca gorda donde se pintan todas las carpetas de tiendas
  Widget _construirListaTickets(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F7FA), // Tonito claro
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: [
          // Esto es magia de Firebase: si cambias algo en la base de datos, 
          // la lista se refresca sola sin tener que hacer F5 ni nada.
          StreamBuilder<List<Ticket>>(
            stream: _servicioTicket.obtenerTicketsUsuario(),
            builder: (context, instantanea) {
              final textos = TextosApp.de(context);
              
              if (instantanea.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (instantanea.hasError) {
                return Center(
                  child: Text(
                    'Ocurrió un error al cargar: ${instantanea.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final tickets = instantanea.data ?? [];
              
              // Filtramos a mano lo que haya escrito el usuario en el buscador
              final ticketsFiltrados = tickets.where((t) {
                return t.nombreComercio.toLowerCase().contains(_consultaBusqueda) ||
                       t.categoria.toLowerCase().contains(_consultaBusqueda);
              }).toList();

              if (ticketsFiltrados.isEmpty) {
                // Si no hay na de na, sacamos un texto triste
                return Center(
                  child: Text(
                    textos.sinComerciosEncontrados,
                    style: const TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                );
              }

              // Metemos todos los tickets que se llamen igual en la misma caja fuerte (diccionario)
              // Así no tenemos 30 carpetas de "Mercadona"
              final Map<String, List<Ticket>> mapaAgrupado = {};
              for (var t in ticketsFiltrados) {
                final clave = t.nombreComercio.trim().toLowerCase();
                if (!mapaAgrupado.containsKey(clave)) {
                  mapaAgrupado[clave] = [];
                }
                mapaAgrupado[clave]!.add(t);
              }
              final grupos = mapaAgrupado.values.toList();

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 100),
                itemCount: grupos.length,
                separatorBuilder: (context, indice) => const SizedBox(height: 20),
                itemBuilder: (context, indice) {
                  final ticketsDelGrupo = grupos[indice];
                  final tituloTienda = ticketsDelGrupo.first.nombreComercio;
                  return TarjetaGrupoComercio(
                    nombreComercio: tituloTienda,
                    tickets: ticketsDelGrupo,
                  );
                },
              );
            },
          ),
          
          // El botón gigante rosa pa' la foto
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: _irAPantallaEscaner,
              icon: const Icon(Icons.camera_alt_rounded),
              label: Text(TextosApp.de(context).escanearTicket.toUpperCase()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 4,
                shadowColor: const Color(0xFFE91E63).withValues(alpha: 0.4),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
