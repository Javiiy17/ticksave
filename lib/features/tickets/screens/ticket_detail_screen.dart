import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/settings/app_settings_scope.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/utils/price_currency.dart';
import '../../../core/utils/raster_image_url.dart';
import '../models/ticket.dart';
import '../services/ticket_service.dart';
import 'alert_screen.dart';
import 'edit_ticket_screen.dart';

/// Pantalla que te muestra el detalle del ticket.
///
/// Le pasamos el [Ticket] desde la lista para enseñarlo y poder editarlo.
/// @author Luis Bermeo
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
    _scannedCode = widget.ticket.scannedCode ?? widget.scannedCode;
    _barcodeFormatLabel = widget.ticket.barcodeFormat ?? widget.barcodeFormatLabel;
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

  Future<void> _deleteTicket() async {
    final t = AppStrings.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF140A26),
        title: Text(t.deleteTicketConfirmTitle, style: const TextStyle(color: Colors.white)),
        content: Text(t.deleteTicketConfirmBody, style: const TextStyle(color: Colors.white70)),
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
      if (widget.ticket.id != null) {
        await TicketService().deleteTicket(widget.ticket.id!);
      }
      if (mounted) Navigator.pop(context, true); // Go back to the previous screen
    }
  }

  Future<void> _shareTicket() async {
    final t = AppStrings.of(context);
    final msg = t.shareTicketMessage(_storeName, _date, _price, code: _scannedCode);
    
    List<XFile> shareFiles = [];
    
    try {
      final tempDir = await getTemporaryDirectory();

      // 1. Imagen física del ticket
      if (_imageUrl.isNotEmpty && _imageUrl.startsWith('http')) {
        final res = await http.get(Uri.parse(rasterHttpUrlOrPlaceholder(_imageUrl)));
        if (res.statusCode == 200) {
          final file = File('${tempDir.path}/ticket_share.jpg');
          await file.writeAsBytes(res.bodyBytes);
          shareFiles.add(XFile(file.path));
        }
      }

      // 2. Imagen generada del formato (QR/BarCode)
      if (_scannedCode != null && _scannedCode!.isNotEmpty) {
        final isQr = _barcodeFormatLabel?.toLowerCase().contains('qr') == true;
        final codeUrl = isQr 
            ? 'https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=$_scannedCode'
            : 'https://barcodeapi.org/api/128/$_scannedCode';
            
        final resCode = await http.get(Uri.parse(codeUrl));
        if (resCode.statusCode == 200) {
          final codeFile = File('${tempDir.path}/code_share.png');
          await codeFile.writeAsBytes(resCode.bodyBytes);
          shareFiles.add(XFile(codeFile.path));
        }
      }
    } catch (e) {
      // Si falla la red, continuamos con modo solo-texto o lo que hayamos bajado
    }
    
    if (shareFiles.isNotEmpty) {
      await Share.shareXFiles(shareFiles, text: msg);
    } else {
      await Share.share(msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF090310), // Tema Pink & Purple base
      appBar: AppBar(
        title: Text(
          t.ticketDetailTitle,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (_scannedCode != null && _scannedCode!.isNotEmpty)
              _buildBarcodeVisualizer()
            else
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

  Widget _buildBarcodeVisualizer() {
    if (_scannedCode == null || _scannedCode!.isEmpty) return const SizedBox.shrink();

    final isQr = _barcodeFormatLabel?.toLowerCase().contains('qr') == true;
    final url = isQr 
        ? 'https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=$_scannedCode'
        : 'https://barcodeapi.org/api/128/$_scannedCode';

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isQr ? 'Escaneando QR' : 'Escaneando Barras',
                    style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 25),
                  Image.network(url, fit: BoxFit.contain, height: 250),
                  const SizedBox(height: 20),
                  Text(_scannedCode!, style: const TextStyle(color: Colors.black54, fontSize: 18, letterSpacing: 2)),
                ],
              ),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          children: [
            Image.network(url, height: 90, fit: BoxFit.contain),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.zoom_out_map, color: Colors.grey.shade600, size: 16),
                const SizedBox(width: 8),
                Text(
                  AppStrings.of(context).tapToEnlarge,
                  style: const TextStyle(color: Colors.black45, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    final t = AppStrings.of(context);
    final bool hasBarcode = _scannedCode != null && _scannedCode!.isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF140A26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _storeName,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                ),
              ),
              if (_categoria.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFE91E63).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                  child: Text(_categoria, style: const TextStyle(color: Color(0xFFE91E63), fontSize: 12, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          if (hasBarcode) ...[
            const SizedBox(height: 15),
            const Divider(color: Colors.white12),
            const SizedBox(height: 15),
            _InfoRow(icon: Icons.qr_code, iconColor: Colors.deepOrange, title: t.codeRead, value: _scannedCode!),
            _InfoRow(icon: Icons.loyalty, iconColor: Colors.teal, title: t.codeFormat, value: _barcodeFormatLabel ?? t.unknownFormat),
          ],
          const SizedBox(height: 15),
          const Divider(color: Colors.white12),
          const SizedBox(height: 15),
          _InfoRow(icon: Icons.calendar_today, iconColor: Colors.greenAccent, title: t.purchaseDate, value: _date),
          const Divider(color: Colors.white12, height: 30),
          _InfoRow(icon: Icons.monetization_on, iconColor: const Color(0xFFFF4081), title: t.ticketAmount, value: PriceCurrency.formatForDisplay(_price, AppSettingsScope.of(context).currencySymbol), valueColor: const Color(0xFFFF4081), isBold: true, isLarge: true),
        ],
      ),
    );
  }

  Widget _buildWarrantySection() {
    final t = AppStrings.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFE91E63), Color(0xFF9C27B0)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.security, color: Colors.white, size: 28),
              const SizedBox(width: 10),
              Text(t.protectWarranty, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Text(t.warrantyAlertHint, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: _openAlertScreen,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF9C27B0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(t.configureAlert),
          )
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    final t = AppStrings.of(context);
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 55,
          child: OutlinedButton.icon(
            onPressed: _shareTicket,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blueAccent,
              side: const BorderSide(color: Colors.blueAccent),
            ),
            icon: const Icon(Icons.share_outlined),
            label: Text(t.shareTicket),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: OutlinedButton.icon(
            onPressed: _openEditTicket,
            icon: const Icon(Icons.edit_outlined),
            label: Text(t.editTicket),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: OutlinedButton.icon(
            onPressed: _deleteTicket,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent),
            ),
            icon: const Icon(Icons.delete_outline),
            label: Text(t.deleteTicket),
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
