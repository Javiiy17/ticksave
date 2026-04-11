import 'package:flutter/material.dart';
import '../../../core/utils/raster_image_url.dart';
import '../../tickets/models/ticket.dart';
import '../screens/store_tickets_screen.dart';
import '../../../core/l10n/app_strings.dart';

class StoreGroupCard extends StatelessWidget {
  const StoreGroupCard({
    super.key,
    required this.storeName,
    required this.tickets,
  });

  final String storeName;
  final List<Ticket> tickets;

  @override
  Widget build(BuildContext context) {
    // Calculamos suma total
    double totalReel = 0.0;
    for (var t in tickets) {
      final stripped = t.price.replaceAll(RegExp(r'[^0-9.,]'), '').replaceAll(',', '.');
      final val = double.tryParse(stripped);
      if (val != null) totalReel += val;
    }

    final String representativeImage = tickets.firstWhere(
      (t) => t.imageUrl.isNotEmpty, 
      orElse: () => tickets.first
    ).imageUrl;

    final safeUrl = rasterHttpUrlOrPlaceholder(representativeImage);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoreTicketsScreen(
              storeName: storeName,
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
                          image: NetworkImage(safeUrl),
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
                          storeName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                          '${tickets.length} ${AppStrings.of(context).receiptX}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${totalReel.toStringAsFixed(2)} €',
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
