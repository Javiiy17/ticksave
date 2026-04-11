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

  Future<void> _deleteFolder() async {
    final t = AppStrings.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF140A26),
        title: Text(t.deleteFolderConfirmTitle, style: const TextStyle(color: Colors.white)),
        content: Text(t.deleteFolderConfirmBody, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.cancel, style: const TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.delete, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      for (final ticket in widget.tickets) {
        if (ticket.id != null) {
          await _ticketService.deleteTicket(ticket.id!);
        }
      }
      if (mounted) Navigator.pop(context);
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Mismo tono suave de listado
      appBar: AppBar(
        title: Text(AppStrings.of(context).storeTicketsTitle(widget.storeName)),
        backgroundColor: const Color(0xFF090310),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
            onPressed: _deleteFolder,
          ),
        ],
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
            onDeleted: () {
              setState(() {
                _localTickets.removeWhere((item) => item.id == t.id);
              });
            },
          );
        },
      ),
    );
  }
}
