import 'package:flutter/material.dart';

import '../../tickets/models/ticket.dart';
import '../../tickets/screens/scan_ticket_screen.dart';
import '../../tickets/screens/edit_store_image_screen.dart';
import '../../tickets/widgets/ticket_store_card.dart';
import '../widgets/header_icon.dart';

/// Pantalla principal que muestra el listado de tickets guardados.
///
/// Para este MVP los datos están en memoria (lista local [tickets]).
/// Más adelante esta pantalla se conectará a un servicio que lea
/// tickets desde Firebase u otra fuente de datos.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Lista de tickets simulada para la demo inicial.
  ///
  /// Aquí podríamos cargar datos reales desde una base de datos.
  final List<Ticket> tickets = [
    Ticket(
      storeName: 'Aldi',
      ticketCount: 2,
      imageUrl:
          'https://images.unsplash.com/photo-1578916171728-46686eac8d58?q=80&w=1000&auto=format&fit=crop',
      prices: ['22,50 €', '18,90 €'],
      dates: ['15/01/2026', '12/01/2026'],
    ),
    Ticket(
      storeName: 'Carrefour',
      ticketCount: 3,
      imageUrl:
          'https://images.unsplash.com/photo-1583258292688-d0213dc5a3a8?q=80&w=1000&auto=format&fit=crop',
      prices: ['89,90 €', '34,20 €', '156,75 €'],
      dates: ['28/01/2026', '25/01/2026', '20/01/2026'],
    ),
    Ticket(
      storeName: 'MediaMarkt',
      ticketCount: 1,
      imageUrl:
          'https://images.unsplash.com/photo-1550009158-9ebf69173e03?q=80&w=1000&auto=format&fit=crop',
      prices: ['599,00 €'],
      dates: ['10/02/2026'],
    ),
  ];

  Future<void> _openEditStoreImage(int index) async {
    final current = tickets[index];

    final newUrl = await Navigator.push<String?>(
      context,
      MaterialPageRoute<String?>(
        builder: (context) => EditStoreImageScreen(
          storeName: current.storeName,
          currentImageUrl: current.imageUrl,
        ),
      ),
    );

    if (newUrl == null || newUrl.isEmpty) {
      return;
    }

    setState(() {
      tickets[index].imageUrl = newUrl;
    });
  }

  void _goToScanScreen() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const ScanTicketScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
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

  /// Franja superior azul con título y contador de tickets.
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mis Tickets',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${tickets.length} tickets guardados',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Row(
            children: const [
              HeaderIcon(icon: Icons.dark_mode_outlined),
              SizedBox(width: 12),
              HeaderIcon(icon: Icons.confirmation_number_outlined),
            ],
          ),
        ],
      ),
    );
  }

  /// Contenedor blanco con la lista de tickets y el botón "Escanear Ticket".
  Widget _buildTicketList(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F7FA),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: [
          ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 100),
            itemCount: tickets.length,
            separatorBuilder: (context, index) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              return TicketStoreCard(
                ticket: tickets[index],
                onEditPressed: () => _openEditStoreImage(index),
              );
            },
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: _goToScanScreen,
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Escanear Ticket'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1877F2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: const Color(0xFF1877F2).withValues(alpha: 0.4),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

