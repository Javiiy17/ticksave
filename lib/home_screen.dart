import 'package:flutter/material.dart';
import 'package:ticksave/scan_ticket_screen.dart';
import 'ticket_detail_screen.dart';
import 'edit_store_image_screen.dart';

// 1. CLASE SIMPLE PARA MANEJAR LOS DATOS (MODELO)
class TicketData {
  String storeName;
  int ticketCount;
  String imageUrl;
  List<String> prices;
  List<String> dates;

  TicketData({
    required this.storeName,
    required this.ticketCount,
    required this.imageUrl,
    required this.prices,
    required this.dates,
  });
}

// 2. CONVERTIDO A STATEFUL WIDGET PARA PODER ACTUALIZARSE
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 3. LISTA DE DATOS QUE SE PUEDE MODIFICAR
  List<TicketData> myTickets = [
    TicketData(
      storeName: "Aldi",
      ticketCount: 2,
      imageUrl: "https://images.unsplash.com/photo-1578916171728-46686eac8d58?q=80&w=1000&auto=format&fit=crop",
      prices: ["22,50 €", "18,90 €"],
      dates: ["15/01/2026", "12/01/2026"],
    ),
    TicketData(
      storeName: "Carrefour",
      ticketCount: 3,
      imageUrl: "https://images.unsplash.com/photo-1583258292688-d0213dc5a3a8?q=80&w=1000&auto=format&fit=crop",
      prices: ["89,90 €", "34,20 €", "156,75 €"],
      dates: ["28/01/2026", "25/01/2026", "20/01/2026"],
    ),
    TicketData(
      storeName: "MediaMarkt",
      ticketCount: 1,
      imageUrl: "https://images.unsplash.com/photo-1550009158-9ebf69173e03?q=80&w=1000&auto=format&fit=crop",
      prices: ["599,00 €"],
      dates: ["10/02/2026"],
    ),
  ];

  // FUNCIÓN PARA NAVEGAR Y ACTUALIZAR
  void _navigateToEdit(int index) async {
    // Esperamos a que la pantalla de edición nos devuelva un dato (la nueva URL)
    final newUrl = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditStoreImageScreen(
          storeName: myTickets[index].storeName,
          currentImageUrl: myTickets[index].imageUrl,
        ),
      ),
    );

    // Si newUrl no es null (es decir, si guardaron cambios)
    if (newUrl != null && newUrl is String) {
      setState(() {
        myTickets[index].imageUrl = newUrl; // Actualizamos la lista
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // --- CABECERA AZUL ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Mis Tickets",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${myTickets.length} tickets guardados", // Contador dinámico
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _HeaderIcon(icon: Icons.dark_mode_outlined),
                      const SizedBox(width: 12),
                      _HeaderIcon(icon: Icons.confirmation_number_outlined),
                    ],
                  )
                ],
              ),
            ),

            // --- CUERPO BLANCO (LISTA) ---
            Expanded(
              child: Container(
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
                    // LISTA GENERADA DINÁMICAMENTE
                    ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 30, 20, 100),
                      itemCount: myTickets.length,
                      separatorBuilder: (c, i) => const SizedBox(height: 20),
                      itemBuilder: (context, index) {
                        final ticket = myTickets[index];
                        return TicketStoreCard(
                          storeName: ticket.storeName,
                          ticketCount: ticket.ticketCount,
                          imageUrl: ticket.imageUrl,
                          prices: ticket.prices,
                          dates: ticket.dates,
                          // Pasamos la función de editar
                          onEditPressed: () => _navigateToEdit(index),
                        );
                      },
                    ),

                    // BOTÓN FLOTANTE
              Positioned(
                bottom: 30,
                left: 20,
                right: 20,
                child: ElevatedButton.icon(
                  // --- AQUÍ ESTÁ EL CAMBIO ---
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ScanTicketScreen()),
                    );
                  },
                  // ---------------------------
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text("Escanear Ticket"),
                  style: ElevatedButton.styleFrom(
                    // ... (tu estilo sigue igual)
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGETS AUXILIARES ---

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  const _HeaderIcon({required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }
}

class TicketStoreCard extends StatelessWidget {
  final String storeName;
  final int ticketCount;
  final String imageUrl;
  final List<String> prices;
  final List<String> dates;
  // Callback nuevo para manejar la edición desde fuera
  final VoidCallback onEditPressed;

  const TicketStoreCard({
    super.key,
    required this.storeName,
    required this.ticketCount,
    required this.imageUrl,
    required this.prices,
    required this.dates,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TicketDetailScreen(
              storeName: storeName,
              date: dates.isNotEmpty ? dates[0] : "N/A",
              price: prices.isNotEmpty ? prices[0] : "0 €",
              imageUrl: imageUrl,
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
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
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
                    shaderCallback: (rect) {
                      return const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black54, Colors.transparent],
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.darken,
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            storeName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                            ),
                          ),
                          Text(
                            "$ticketCount tickets",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      // USAMOS EL CALLBACK AQUÍ
                      GestureDetector(
                        onTap: onEditPressed, // Llamamos a la función del padre
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 70,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: prices.length,
                  separatorBuilder: (c, i) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    return Container(
                      width: 120,
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
                            prices[index],
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dates[index],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}