import 'package:flutter/material.dart';

import '../../../core/settings/app_settings_scope.dart';
import '../../../core/utils/price_currency.dart';
import '../../../core/utils/raster_image_url.dart';
import '../models/ticket.dart';
import 'alert_screen.dart';
import 'edit_ticket_screen.dart';

/// Muestra el detalle de un ticket concreto.
///
/// Puede enlazarse a un [Ticket] del listado para persistir ediciones en memoria.
class TicketDetailScreen extends StatefulWidget {
  const TicketDetailScreen({
    super.key,
    required this.storeName,
    required this.date,
    required this.price,
    required this.imageUrl,
    this.scannedCode,
    this.barcodeFormatLabel,
    this.sourceTicket,
    this.sourceLineIndex = 0,
  });

  final String storeName;
  final String date;
  final String price;
  final String imageUrl;

  /// Valor decodificado del QR o código de barras (si se llegó desde el escáner).
  final String? scannedCode;

  /// Etiqueta legible del formato (p. ej. EAN-13, Code 128).
  final String? barcodeFormatLabel;

  /// Si no es null, las ediciones actualizan este modelo (MVP en memoria).
  final Ticket? sourceTicket;

  /// Índice en [Ticket.prices] / [Ticket.dates] que representa esta línea.
  final int sourceLineIndex;

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  late String _storeName;
  late String _date;
  late String _price;
  late String _imageUrl;
  String? _scannedCode;
  String? _barcodeFormatLabel;

  @override
  void initState() {
    super.initState();
    _storeName = widget.storeName;
    _date = widget.date;
    _price = widget.price;
    _imageUrl = widget.imageUrl;
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

    final t = widget.sourceTicket;
    if (t != null) {
      t.storeName = _storeName;
      final i = widget.sourceLineIndex;
      if (i >= 0 && i < t.prices.length && i < t.dates.length) {
        t.prices[i] = _price;
        t.dates[i] = _date;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Detalle del Ticket',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
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
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage(rasterHttpUrlOrPlaceholder(_imageUrl)),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.storefront,
            iconColor: Colors.blue,
            title: 'Comercio',
            value: _storeName,
            isBold: true,
          ),
          if (_scannedCode != null && _scannedCode!.isNotEmpty) ...[
            const Divider(height: 30, color: Colors.grey),
            _InfoRow(
              icon: Icons.qr_code_scanner,
              iconColor: Colors.deepOrange,
              title: 'Código leído',
              value: _scannedCode!,
            ),
          ],
          if (_barcodeFormatLabel != null &&
              _barcodeFormatLabel!.isNotEmpty) ...[
            const Divider(height: 30, color: Colors.grey),
            _InfoRow(
              icon: Icons.view_week_outlined,
              iconColor: Colors.teal,
              title: 'Formato',
              value: _barcodeFormatLabel!,
            ),
          ],
          const Divider(height: 30, color: Colors.grey),
          _InfoRow(
            icon: Icons.calendar_today,
            iconColor: Colors.green,
            title: 'Fecha de compra',
            value: _date,
          ),
          const Divider(height: 30, color: Colors.grey),
          _InfoRow(
            icon: Icons.attach_money,
            iconColor: Colors.purple,
            title: 'Importe',
            value: PriceCurrency.formatForDisplay(
              _price,
              AppSettingsScope.of(context).currencySymbol,
            ),
            valueColor: Colors.blue[700],
            isBold: true,
            isLarge: true,
          ),
        ],
      ),
    );
  }

  Widget _buildWarrantySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBBDEFB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.notifications_none,
            color: Color(0xFF1976D2),
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
                    color: Color(0xFF1565C0),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Configura una alerta para recordar el vencimiento de la garantía',
                  style: const TextStyle(
                    color: Colors.black,
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
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _openAlertScreen,
            icon: const Icon(Icons.notifications_active_outlined),
            label: const Text('Configurar Alerta'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1877F2),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: _openEditTicket,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Editar Ticket'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black87,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.white,
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Fila de información utilizada dentro de la tarjeta de detalle.
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
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: valueColor ?? Colors.black87,
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
