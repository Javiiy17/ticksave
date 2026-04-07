import 'dart:math' show max;

import 'package:flutter/material.dart';

import '../../../core/settings/app_settings_scope.dart';
import '../../../core/utils/price_currency.dart';
import '../../../core/utils/raster_image_url.dart';
import '../models/ticket.dart';
import '../screens/ticket_detail_screen.dart';

/// Tarjeta que resume los tickets de una tienda.
///
/// - Muestra imagen de cabecera.
/// - Nombre del comercio y número de tickets.
/// - Lista horizontal de importes y fechas.
/// - Cada chip abre el detalle de ese ticket; la cabecera abre el primero.
class TicketStoreCard extends StatelessWidget {
  const TicketStoreCard({
    super.key,
    required this.ticket,
    required this.onEditPressed,
  });

  final Ticket ticket;

  /// Acción que permite editar la imagen de la tienda desde la pantalla padre.
  final VoidCallback onEditPressed;

  void _openTicketDetail(BuildContext context, int lineIndex) {
    final date = lineIndex < ticket.dates.length
        ? ticket.dates[lineIndex]
        : 'N/A';
    final price = lineIndex < ticket.prices.length
        ? ticket.prices[lineIndex]
        : '0 €';

    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => TicketDetailScreen(
          storeName: ticket.storeName,
          date: date,
          price: price,
          imageUrl: ticket.imageUrl,
          sourceTicket: ticket,
          sourceLineIndex: lineIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _openTicketDetail(context, 0),
            child: _buildHeaderImage(context),
          ),
          _buildTicketChips(context),
        ],
      ),
    );
  }

  Widget _buildHeaderImage(BuildContext context) {
    final safeUrl = rasterHttpUrlOrPlaceholder(ticket.imageUrl);
    return Stack(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket.storeName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                    ),
                  ),
                  Text(
                    '${ticket.ticketCount} tickets',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Material(
                color: Colors.white,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onEditPressed,
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

  Widget _buildTicketChips(BuildContext context) {
    final lineCount = max(ticket.prices.length, ticket.dates.length);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 70,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: lineCount,
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final rawPrice = index < ticket.prices.length
                ? ticket.prices[index]
                : '—';
            final symbol = AppSettingsScope.of(context).currencySymbol;
            final price = rawPrice == '—'
                ? rawPrice
                : PriceCurrency.formatForDisplay(rawPrice, symbol);
            final date = index < ticket.dates.length
                ? ticket.dates[index]
                : 'N/A';

            return Material(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => _openTicketDetail(context, index),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 120,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        price,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

