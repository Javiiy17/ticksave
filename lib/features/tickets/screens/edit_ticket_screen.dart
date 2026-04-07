import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/settings/app_settings_scope.dart';
import '../../../core/utils/price_currency.dart';

/// Datos que devuelve [EditTicketScreen] al guardar.
class EditTicketResult {
  const EditTicketResult({
    required this.storeName,
    required this.date,
    required this.price,
  });

  final String storeName;
  final String date;
  final String price;
}

/// Formulario para editar comercio, fecha e importe del ticket.
///
/// Estilo alineado con [AlertScreen] y [EditStoreImageScreen]: fondo claro,
/// tarjetas blancas, acento azul y textos oscuros sobre campos claros.
class EditTicketScreen extends StatefulWidget {
  const EditTicketScreen({
    super.key,
    required this.initialStoreName,
    required this.initialDate,
    required this.initialPrice,
    this.scannedCode,
    this.barcodeFormatLabel,
  });

  final String initialStoreName;
  final String initialDate;
  final String initialPrice;
  final String? scannedCode;
  final String? barcodeFormatLabel;

  @override
  State<EditTicketScreen> createState() => _EditTicketScreenState();
}

class _EditTicketScreenState extends State<EditTicketScreen> {
  late final TextEditingController _storeController;
  late final TextEditingController _dateController;
  late final TextEditingController _priceController;

  static const TextStyle _fieldTextStyle = TextStyle(color: Color(0xFF111827));

  @override
  void initState() {
    super.initState();
    _storeController = TextEditingController(text: widget.initialStoreName);
    _dateController = TextEditingController(text: widget.initialDate);
    _priceController = TextEditingController(
      text: PriceCurrency.stripKnownSuffixes(widget.initialPrice),
    );
  }

  @override
  void dispose() {
    _storeController.dispose();
    _dateController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _save() {
    final store = _storeController.text.trim();
    final date = _dateController.text.trim();
    final amount = _priceController.text.trim();

    if (store.isEmpty || date.isEmpty || amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.of(context).fillStoreDatePrice)),
      );
      return;
    }

    final symbol = AppSettingsScope.of(context).currencySymbol;
    final price = PriceCurrency.withSymbol(amount, symbol);

    Navigator.pop(
      context,
      EditTicketResult(storeName: store, date: date, price: price),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Editar ticket',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainFieldsCard(context),
            if (_hasScanInfo) ...[
              const SizedBox(height: 20),
              _buildScanInfoCard(),
            ],
            const SizedBox(height: 30),
            _buildActions(),
            const SizedBox(height: 24),
            _buildHintCard(),
          ],
        ),
      ),
    );
  }

  bool get _hasScanInfo =>
      (widget.scannedCode != null && widget.scannedCode!.isNotEmpty) ||
      (widget.barcodeFormatLabel != null &&
          widget.barcodeFormatLabel!.isNotEmpty);

  Widget _buildMainFieldsCard(BuildContext context) {
    final currencySuffix = ' ${AppSettingsScope.of(context).currencySymbol}';

    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.storefront_outlined, 'Datos del ticket', Colors.blue),
          const SizedBox(height: 20),
          _labeledField(
            label: 'Comercio',
            controller: _storeController,
            hint: 'Nombre de la tienda',
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          _labeledField(
            label: 'Fecha de compra',
            controller: _dateController,
            hint: 'dd/mm/aaaa',
            keyboardType: TextInputType.datetime,
          ),
          const SizedBox(height: 16),
          _labeledField(
            label: 'Importe',
            controller: _priceController,
            hint: 'Ej: 24,99',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            suffixText: currencySuffix,
            suffixStyle: _fieldTextStyle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanInfoCard() {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            Icons.qr_code_scanner,
            'Datos del escaneo',
            Colors.deepOrange,
          ),
          const SizedBox(height: 12),
          Text(
            'Estos datos vienen del código leído y no se modifican aquí.',
            style: TextStyle(color: Colors.black.withValues(alpha: 0.75), fontSize: 13),
          ),
          if (widget.scannedCode != null && widget.scannedCode!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _readOnlyRow('Código', widget.scannedCode!),
          ],
          if (widget.barcodeFormatLabel != null &&
              widget.barcodeFormatLabel!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _readOnlyRow('Formato', widget.barcodeFormatLabel!),
          ],
        ],
      ),
    );
  }

  Widget _readOnlyRow(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: Color(0xFF111827), fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _save,
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
            child: const Text('Guardar cambios'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
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
            child: const Text('Cancelar'),
          ),
        ),
      ],
    );
  }

  Widget _buildHintCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBBDEFB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: Colors.orange, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Los cambios se aplican a este ticket. Para cambiar la foto del comercio, usa el lápiz en la tarjeta del inicio.',
              style: TextStyle(color: Colors.blue[900], fontSize: 13, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _labeledField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? suffixText,
    TextStyle? suffixStyle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: _fieldTextStyle,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixText: suffixText,
            suffixStyle: suffixStyle,
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _whiteCard({required Widget child}) {
    return Container(
      width: double.infinity,
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
      child: child,
    );
  }
}
