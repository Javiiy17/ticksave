import 'package:flutter/material.dart';

import '../../../core/settings/app_settings_scope.dart';
import '../../../core/utils/price_currency.dart';
import '../../../core/utils/raster_image_url.dart';
import '../models/ticket.dart';
import '../services/ticket_service.dart';
import 'alert_screen.dart';
import 'edit_ticket_screen.dart';

/// Pantalla que te muestra el detalle del ticket.
///
/// Le pasamos el [Ticket] desde la lista para enseñarlo y poder editarlo.
class TicketDetailScreen extends StatefulWidget {
  const TicketDetailScreen({
    super.key,
    required this.ticket,
    this.scannedCode,
    this.barcodeFormatLabel,
    this.sourceTicket,
    this.sourceLineIndex = 0,
  });

  final Ticket ticket;

  /// Valor que pillamos del código QR o de barras si vienes del escáner.
  final String? scannedCode;

  /// Tipo de código de barras (ej. EAN-13), por si hace falta.
  final String? barcodeFormatLabel;

  /// El ticket original que estamos tocando, para no liar los IDs.
  final Ticket? sourceTicket;

  /// Por la parte de código que hizo Javi, nos guardamos el índice.
  final int sourceLineIndex;

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  late String _storeName;
  late String _date;
  late String _price;
  late String _imageUrl;
  late String _categoria;
  String? _scannedCode;
  String? _barcodeFormatLabel;

  @override
  void initState() {
    super.initState();
    _storeName = widget.ticket.storeName;
    _date = widget.ticket.formattedDate;
    _price = widget.ticket.price;
    _imageUrl = widget.ticket.imageUrl;
    _categoria = widget.ticket.categoria;
    _scannedCode = widget.scannedCode;
    _barcodeFormatLabel = widget.barcodeFormatLabel;
  }

  void _openAlertScreen() {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => AlertScreen(
          storeName: _storeName,
          purchaseDate: _date,
        ),
      ),
    );
  }

  Future<void> _openEditTicket() async {
    final result = await Navigator.push<EditTicketResult>(
      context,
      MaterialPageRoute<EditTicketResult>(
        builder: (context) => EditTicketScreen(
          initialStoreName: _storeName,
          initialDate: _date,
          initialPrice: _price,
          scannedCode: _scannedCode,
          barcodeFormatLabel: _barcodeFormatLabel,
        ),
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      _storeName = result.storeName;
      _date = result.date;
      _price = result.price;
    });

    // Actualizamos el ticket local y lo mandamos a la nube
    final t = widget.sourceTicket ?? (widget.ticket.id != null ? widget.ticket : null);
    if (t != null) {
      t.storeName = _storeName;
      t.price = _price;
      // Ojo: no estamos tocando la fecha aquí para no complicarlo mucho más
      
      // Que no se nos olvide subir esto a Firebase
      await TicketService().updateTicket(t);
    }
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
    if (_imageUrl.isEmpty) {
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
          image: NetworkImage(rasterHttpUrlOrPlaceholder(_imageUrl)),
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
            value: _storeName,
            isBold: true,
          ),
          if (_scannedCode != null && _scannedCode!.isNotEmpty) ...[
            const Divider(height: 30, color: Colors.white12),
            _InfoRow(
              icon: Icons.qr_code_scanner,
              iconColor: Colors.deepOrange,
              title: 'Código leído',
              value: _scannedCode!,
            ),
          ],
          if (_barcodeFormatLabel != null &&
              _barcodeFormatLabel!.isNotEmpty) ...[
            const Divider(height: 30, color: Colors.white12),
            _InfoRow(
              icon: Icons.view_week_outlined,
              iconColor: Colors.teal,
              title: 'Formato',
              value: _barcodeFormatLabel!,
            ),
          ],
          const Divider(height: 30, color: Colors.white12),
          _InfoRow(
            icon: Icons.calendar_today,
            iconColor: Colors.greenAccent,
            title: 'Fecha de compra',
            value: _date,
          ),
          const Divider(height: 30, color: Colors.white12),
          _InfoRow(
            icon: Icons.attach_money,
            iconColor: const Color(0xFFFF4081),
            title: 'Importe',
            value: PriceCurrency.formatForDisplay(
              _price,
              AppSettingsScope.of(context).currencySymbol,
            ),
            valueColor: const Color(0xFFFF4081),
            isBold: true,
            isLarge: true,
          ),
          const Divider(height: 30, color: Colors.white12),
          _InfoRow(
            icon: Icons.category_rounded,
            iconColor: Colors.orangeAccent,
            title: 'Categoría',
            value: _categoria,
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Protege tu garantía',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
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
            onPressed: _openAlertScreen,
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
            onPressed: _openEditTicket,
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
        Expanded(
          child: Column(
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
        ),
      ],
    );
  }
}
