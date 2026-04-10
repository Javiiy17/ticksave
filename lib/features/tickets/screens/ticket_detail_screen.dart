import 'package:flutter/material.dart';

import '../models/ticket.dart';
import 'alert_screen.dart';
import 'edit_ticket_screen.dart';

/// Muestra el detalle de un ticket concreto.
class TicketDetailScreen extends StatelessWidget {
  const TicketDetailScreen({
    super.key,
    required this.ticket,
  });

  final Ticket ticket;

  void _openAlertScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => AlertScreen(
          storeName: ticket.storeName,
          purchaseDate: ticket.formattedDate,
        ),
      ),
    );
  }

  void _openEditScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => EditTicketScreen(
          existingTicket: ticket,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090310), // Tema Pink & Purple base
      appBar: AppBar(
        title: const Text(
          'Detalle del Ticket',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeaderImage(),
            const SizedBox(height: 20),
            _buildInfoCard(),
            const SizedBox(height: 20),
            _buildWarrantySection(),
            const SizedBox(height: 30),
            _buildButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderImage() {
    if (ticket.imageUrl.isEmpty) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF140A26),
          borderRadius: BorderRadius.circular(25),
        ),
        child: const Center(
          child: Icon(Icons.receipt_long, size: 80, color: Colors.white54),
        ),
      );
    }
    
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        image: DecorationImage(
          image: NetworkImage(ticket.imageUrl),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF4081).withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF140A26),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.storefront,
            iconColor: Colors.blueAccent,
            title: 'Comercio',
            value: ticket.storeName,
            isBold: true,
          ),
          const Divider(height: 30, color: Colors.white12),
          _InfoRow(
            icon: Icons.calendar_today,
            iconColor: Colors.greenAccent,
            title: 'Fecha de compra',
            value: ticket.formattedDate,
          ),
          const Divider(height: 30, color: Colors.white12),
          _InfoRow(
            icon: Icons.attach_money,
            iconColor: const Color(0xFFFF4081),
            title: 'Importe',
            value: ticket.price,
            valueColor: Colors.white,
            isBold: true,
            isLarge: true,
          ),
          const Divider(height: 30, color: Colors.white12),
          _InfoRow(
            icon: Icons.category_rounded,
            iconColor: Colors.orangeAccent,
            title: 'Categoría',
            value: ticket.categoria,
          ),
        ],
      ),
    );
  }

  Widget _buildWarrantySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE91E63).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFE91E63).withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.notifications_active_rounded,
            color: Color(0xFFFF4081),
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Protege tu garantía',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Configura una alerta para recordar el vencimiento de la garantía',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            onPressed: () => _openAlertScreen(context),
            icon: const Icon(Icons.notifications_active_outlined),
            label: const Text('Configurar Alerta'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: OutlinedButton.icon(
            onPressed: () => _openEditScreen(context),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Editar Ticket'),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    this.valueColor,
    this.isBold = false,
    this.isLarge = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final Color? valueColor;
  final bool isBold;
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: isLarge ? 20 : 16,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

