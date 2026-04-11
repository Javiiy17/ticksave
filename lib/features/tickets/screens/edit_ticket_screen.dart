import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/ticket.dart';
import '../services/ticket_service.dart';
import '../../home/screens/home_screen.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/settings/app_settings_scope.dart';
import '../../../core/utils/price_currency.dart';

/// Datos que devuelve [EditTicketScreen] al guardar cuando se usa desde el detalle.
/// @author Luis Bermeo
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

/// Pantalla para crear un ticket desde cero o editar uno existente.
/// Comparte los parámetros para ser compatible con OCR y otros flujos.
/// @author Luis Bermeo
class EditTicketScreen extends StatefulWidget {
  final Ticket? existingTicket;
  final String? scannedStoreName;
  final String? scannedDate;
  final String? initialPrice;
  final File? newImageFile;
  final String? scannedCode;
  final String? barcodeFormatLabel;

  /// Constructores combinados para soportar ambos flujos (Scan y Detail Edit)
  const EditTicketScreen({
    super.key,
    this.existingTicket,
    this.scannedStoreName,
    this.scannedDate,
    this.initialPrice,
    this.newImageFile,
    this.scannedCode,
    this.barcodeFormatLabel,
    // Compatibilidad con parámetros nombrados del partner
    String? initialStoreName,
    String? initialDate,
  }) : 
    // Mapeo de parámetros para compatibilidad
    _compatStoreName = initialStoreName,
    _compatDate = initialDate;

  final String? _compatStoreName;
  final String? _compatDate;

  @override
  State<EditTicketScreen> createState() => _EditTicketScreenState();
}

class _EditTicketScreenState extends State<EditTicketScreen> {
  final TicketService _ticketService = TicketService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _storeController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;
  late TextEditingController _dateController;
  late TextEditingController _scannedCodeController;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _storeController = TextEditingController(
      text: widget.existingTicket?.storeName ?? 
            widget.scannedStoreName ?? 
            widget._compatStoreName ?? ''
    );
    _priceController = TextEditingController(
      text: widget.existingTicket?.price != null 
            ? PriceCurrency.stripKnownSuffixes(widget.existingTicket!.price) 
            : (widget.initialPrice != null ? PriceCurrency.stripKnownSuffixes(widget.initialPrice!) : '')
    );
    _categoryController = TextEditingController(
      text: widget.existingTicket?.categoria ?? 'General'
    );
    _dateController = TextEditingController(
      text: widget.existingTicket?.formattedDate ?? 
            widget.scannedDate ?? 
            widget._compatDate ?? ''
    );
    _scannedCodeController = TextEditingController(
      text: widget.existingTicket?.scannedCode ?? widget.scannedCode ?? ''
    );
  }

  @override
  void dispose() {
    _storeController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _dateController.dispose();
    _scannedCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    // Si venimos del detalle (partner flow), devolvemos el resultado
    if (widget.existingTicket != null || widget._compatStoreName != null) {
       final symbol = AppSettingsScope.of(context).currencySymbol;
       final priceWithSymbol = PriceCurrency.withSymbol(_priceController.text.trim(), symbol);
       
       // Si es una edición real en Firebase (flow original)
       if (widget.existingTicket != null && widget.existingTicket!.id != null) {
          await _saveToFirebase();
       } else {
         // Si es solo retorno de datos (flow partner)
         Navigator.pop(
           context,
           EditTicketResult(
             storeName: _storeController.text.trim(),
             date: _dateController.text.trim(),
             price: priceWithSymbol,
           ),
         );
       }
    } else {
      // Si venimos del escáner (creación nueva)
      await _saveToFirebase();
    }
  }

  Future<void> _saveToFirebase() async {
    setState(() => _isLoading = true);
    try {
      String imageUrl = widget.existingTicket?.imageUrl ?? '';

      if (widget.newImageFile != null) {
        final url = await _ticketService.uploadTicketImage(widget.newImageFile!);
        if (url != null) imageUrl = url;
      }

      DateTime parsedDate;
      try {
        parsedDate = DateFormat('dd/MM/yyyy').parse(_dateController.text.trim());
      } catch (_) {
        parsedDate = DateTime.now();
      }

      final newTicketData = Ticket(
        id: widget.existingTicket?.id,
        storeName: _storeController.text.trim(),
        price: '${_priceController.text.trim().replaceAll(',', '.')} €', 
        purchaseDate: parsedDate,
        imageUrl: imageUrl,
        categoria: _categoryController.text.trim(),
        scannedCode: _scannedCodeController.text.trim().isNotEmpty ? _scannedCodeController.text.trim() : null,
        barcodeFormat: widget.existingTicket?.barcodeFormat ?? widget.barcodeFormatLabel,
      );

      if (widget.existingTicket == null) {
        await _ticketService.addTicket(newTicketData);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.of(context).ticketCreatedSuccess), backgroundColor: Colors.green),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        await _ticketService.updateTicket(newTicketData);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.of(context).ticketUpdatedSuccess), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().contains('Timeout') 
              ? 'Error: Falla conexión en bdd' 
              : 'Error al guardar: $e'), 
            backgroundColor: Colors.redAccent
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final bool isEditing = widget.existingTicket != null || widget._compatStoreName != null;
    
    return Scaffold(
      backgroundColor: const Color(0xFF090310),
      appBar: AppBar(
        title: Text(isEditing ? t.editTicketTitle : t.saveNewTicket),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildImagePreview(),
              const SizedBox(height: 25),
              _buildTextField(
                controller: _storeController,
                label: t.storeLabel,
                icon: Icons.storefront,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _dateController,
                label: t.dateLabel,
                icon: Icons.calendar_today,
                hint: 'dd/mm/aaaa',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.today, color: Color(0xFFE91E63)),
                  onPressed: () {
                    setState(() {
                      _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _priceController,
                label: t.priceLabel,
                icon: Icons.attach_money,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+[,.]?\d*')),
                ],
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _categoryController,
                label: t.category,
                icon: Icons.category,
              ),
              if (_scannedCodeController.text.isNotEmpty || widget.barcodeFormatLabel != null) 
                _buildBarcodeInfoSection(),
              const SizedBox(height: 40),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarcodeInfoSection() {
    final t = AppStrings.of(context);
    final formatLabel = widget.existingTicket?.barcodeFormat ?? widget.barcodeFormatLabel ?? t.unknownFormat;
    final isQr = formatLabel.toLowerCase().contains('qr');
    final codeValue = _scannedCodeController.text;
    
    // Si borran el código, no renderizar imagen fantasma
    if (codeValue.isEmpty) return const SizedBox.shrink();

    final url = isQr 
        ? 'https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=$codeValue'
        : 'https://barcodeapi.org/api/128/$codeValue';

    return Container(
      margin: const EdgeInsets.only(top: 30),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF140A26),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.codeInfo,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _scannedCodeController,
            label: t.cardIdLabel,
            icon: Icons.pin_outlined,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                const Icon(Icons.qr_code_scanner, color: Colors.white70),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.formatDetected, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(formatLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Visualización animada en blanco para simular la vista
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Image.network(
              url, 
              height: 100, 
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.qr_code, color: Colors.black26, size: 80),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    if (widget.newImageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Image.file(widget.newImageFile!, height: 200, width: double.infinity, fit: BoxFit.cover),
      );
    } else if (widget.existingTicket?.imageUrl.isNotEmpty == true) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Image.network(widget.existingTicket!.imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final t = AppStrings.of(context);
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFFF4081)),
        ),
      ),
      validator: (val) => val!.isEmpty ? t.requiredField : null,
    );
  }

  Widget _buildSaveButton() {
    final t = AppStrings.of(context);
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSave,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFE91E63), Color(0xFF9C27B0)]),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Container(
            alignment: Alignment.center,
            height: 55,
            child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    t.saveTicketButton,
                    style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }
}
