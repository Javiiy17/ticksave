import 'package:flutter/material.dart';
import '../../tickets/models/ticket.dart';
import '../widgets/ticket_store_card.dart';
import 'edit_store_image_screen.dart';
import '../../tickets/services/ticket_service.dart';
import '../../../core/l10n/app_strings.dart';

class StoreTicketsScreen extends StatefulWidget {
  final String storeName;
  final List<Ticket> tickets;

  const StoreTicketsScreen({
    super.key,
    required this.storeName,
    required this.tickets,
  });

  @override
  State<StoreTicketsScreen> createState() => _StoreTicketsScreenState();
}

class _StoreTicketsScreenState extends State<StoreTicketsScreen> {
  final TicketService _ticketService = TicketService();
  late List<Ticket> _localTickets;

  @override
  void initState() {
    super.initState();
    _localTickets = List.from(widget.tickets);
    // Ordenar por fecha más reciente
    _localTickets.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
  }

  void _openEditStoreImage(Ticket current) async {
    final newUrl = await Navigator.push<String?>(
      context,
      MaterialPageRoute<String?>(
        builder: (context) => EditStoreImageScreen(
          storeName: current.storeName,
          currentImageUrl: current.imageUrl,
        ),
      ),
    );

    if (newUrl == null || newUrl.isEmpty) return;

    current.imageUrl = newUrl;
    await _ticketService.updateTicket(current);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Mismo tono suave de listado
      appBar: AppBar(
        title: Text(AppStrings.of(context).storeTicketsTitle(widget.storeName)),
        backgroundColor: const Color(0xFF090310),
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _localTickets.length,
        separatorBuilder: (context, index) => const SizedBox(height: 20),
        itemBuilder: (context, index) {
          final t = _localTickets[index];
          return TicketStoreCard(
            ticket: t,
            onEditPressed: () => _openEditStoreImage(t),
          );
        },
      ),
    );
  }
}
