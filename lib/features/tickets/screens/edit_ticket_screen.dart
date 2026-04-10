import 'dart:io';
import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../services/ticket_service.dart';
import '../../home/screens/home_screen.dart';
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
  }

  @override
  void dispose() {
    _storeController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _dateController.dispose();
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

      final newTicketData = Ticket(
        id: widget.existingTicket?.id,
        storeName: _storeController.text.trim(),
        price: '${_priceController.text.trim()} €', // O usar PriceCurrency
        purchaseDate: DateTime.now(), // Aquí se debería parsear _dateController si se quiere precisión
        imageUrl: imageUrl,
        categoria: _categoryController.text.trim(),
      );

      if (widget.existingTicket == null) {
        await _ticketService.addTicket(newTicketData);
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        await _ticketService.updateTicket(newTicketData);
        if (!mounted) return;
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.existingTicket != null || widget._compatStoreName != null;
    
    return Scaffold(
      backgroundColor: const Color(0xFF090310),
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Ticket' : 'Guardar Nuevo Ticket'),
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
                label: 'Comercio / Tienda',
                icon: Icons.storefront,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _dateController,
                label: 'Fecha',
                icon: Icons.calendar_today,
                hint: 'dd/mm/aaaa',
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _priceController,
                label: 'Precio',
                icon: Icons.attach_money,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _categoryController,
                label: 'Categoría',
                icon: Icons.category,
              ),
              const SizedBox(height: 40),
              _buildSaveButton(),
            ],
          ),
        ),
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
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFFF4081)),
        ),
      ),
      validator: (val) => val!.isEmpty ? 'Campo requerido' : null,
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
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
                : const Text(
                    'GUARDAR TICKET',
                    style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
          ),
        ),
      ),
    );
  }
}
