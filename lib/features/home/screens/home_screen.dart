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

/// Pantalla principal que muestra el listado de tickets guardados desde Firebase.
/// Maneja la UI de búsqueda y el panel inferior.
/// @author Luis Bermeo
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TicketService _ticketService = TicketService();
  String _searchQuery = "";

  // El comportamiento de edición individual ahora está en StoreTicketsScreen.
  // Solo lo dejamos por si hiciera falta a nivel global.
  /// Muestra un menú inferior (BottomSheet) para que el usuario elija
  /// si desea escanear el ticket mediante OCR (foto) o escanear un
  /// código de barras / QR de forma rápida.
  /// @author Javier Abellán
  void _goToScanScreen() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        final t = AppStrings.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.chooseScanMode,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.document_scanner, color: Color(0xFFE91E63)),
                  title: Text(t.scanOcrTitle),
                  subtitle: Text(t.scanOcrSubtitle),
                  onTap: () {
                    Navigator.pop(context); // Cerrar Modal
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ScanTicketScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.qr_code_scanner, color: Color(0xFFE91E63)),
                  title: Text(t.scanBarcodeTitle),
                  subtitle: Text(t.scanBarcodeSubtitle),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
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
            _buildHeader(context),
            Expanded(child: _buildTicketList(context)),
          ],
        ),
      ),
    );
  }

  /// Franja superior con título, buscador y opciones.
  Widget _buildHeader(BuildContext context) {
    final t = AppStrings.of(context);

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
                    t.homeTitle,
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
                  HeaderIcon(
                    icon: Icons.settings_outlined,
                    onTap: () {
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  HeaderIcon(
                    icon: Icons.logout,
                    onTap: () async {
                      await AuthService().signOut();
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
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
              hintText: t.searchStore,
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
            ),
            onChanged: (val) {
              setState(() {
                _searchQuery = val.toLowerCase();
              });
            },
          )
        ],
      ),
    );
  }

  /// Contenedor blanco con la lista de tickets que usa StreamBuilder
  Widget _buildTicketList(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F7FA), // Light theme underneath / could change for dark mode
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: [
          StreamBuilder<List<Ticket>>(
            stream: _ticketService.getUserTickets(),
            builder: (context, snapshot) {
              final t = AppStrings.of(context);
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Ocurrió un error al cargar: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final tickets = snapshot.data ?? [];
              
              // Filtrado local pre-existente
              final filteredTickets = tickets.where((t) {
                return t.storeName.toLowerCase().contains(_searchQuery) ||
                       t.categoria.toLowerCase().contains(_searchQuery);
              }).toList();

              if (filteredTickets.isEmpty) {
                return Center(
                  child: Text(
                    t.noStoresFound,
                    style: const TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                );
              }

              // Agrupación de tickets por nombre ignorando case (Carpetas)
              final Map<String, List<Ticket>> groupedMap = {};
              for (var t in filteredTickets) {
                final key = t.storeName.trim().toLowerCase();
                if (!groupedMap.containsKey(key)) {
                  groupedMap[key] = [];
                }
                groupedMap[key]!.add(t);
              }
              final groups = groupedMap.values.toList();

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 100),
                itemCount: groups.length,
                separatorBuilder: (context, index) => const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  final groupTickets = groups[index];
                  final storeNameTitle = groupTickets.first.storeName;
                  return StoreGroupCard(
                    storeName: storeNameTitle,
                    tickets: groupTickets,
                  );
                },
              );
            },
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: _goToScanScreen,
              icon: const Icon(Icons.camera_alt_rounded),
              label: Text(AppStrings.of(context).scanTicket.toUpperCase()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63), // Pink Gradient color emulation
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
