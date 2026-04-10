import 'dart:io';

import 'package:flutter/material.dart';
import '../../tickets/models/ticket.dart';
import '../../tickets/services/ticket_service.dart';
import '../../home/screens/home_screen.dart';

class EditTicketScreen extends StatefulWidget {
  final Ticket? existingTicket;
  final String? scannedStoreName;
  final String? scannedDate;
  final File? newImageFile;

  const EditTicketScreen({
    super.key,
    this.existingTicket,
    this.scannedStoreName,
    this.scannedDate,
    this.newImageFile,
  });

  @override
  State<EditTicketScreen> createState() => _EditTicketScreenState();
}

class _EditTicketScreenState extends State<EditTicketScreen> {
  final TicketService _ticketService = TicketService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _storeController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _storeController = TextEditingController(
        text: widget.existingTicket?.storeName ?? widget.scannedStoreName ?? '');
    _priceController = TextEditingController(
        text: widget.existingTicket?.price ?? '');
    _categoryController = TextEditingController(
        text: widget.existingTicket?.categoria ?? 'General');
  }

  @override
  void dispose() {
    _storeController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _saveTicket() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String imageUrl = widget.existingTicket?.imageUrl ?? '';

      // Upload image if there is a new one (e.g. from camera)
      if (widget.newImageFile != null) {
        final url = await _ticketService.uploadTicketImage(widget.newImageFile!);
        if (url != null) imageUrl = url;
      }

      DateTime date = widget.existingTicket?.purchaseDate ?? DateTime.now();
      // En un futuro el scannedDate se puede parsear si es estricto.

      final newTicketData = Ticket(
        id: widget.existingTicket?.id,
        storeName: _storeController.text.trim(),
        price: '${_priceController.text.trim()} €',
        purchaseDate: date,
        imageUrl: imageUrl,
        categoria: _categoryController.text.trim(),
      );

      if (widget.existingTicket == null) {
        // Create new
        await _ticketService.addTicket(newTicketData);
        if (!mounted) return;
        // Go back to home to avoid pushing duplicate scan screens
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        // Update existing
        await _ticketService.updateTicket(newTicketData);
        if (!mounted) return;
        Navigator.pop(context, true); // Return to detail
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.existingTicket != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Ticket' : 'Guardar Nuevo Ticket'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (widget.newImageFile != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.file(widget.newImageFile!, height: 200, width: double.infinity, fit: BoxFit.cover),
                ),
                const SizedBox(height: 20),
              ] else if (widget.existingTicket?.imageUrl.isNotEmpty == true) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.network(widget.existingTicket!.imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
                ),
                const SizedBox(height: 20),
              ],
              TextFormField(
                controller: _storeController,
                decoration: const InputDecoration(labelText: 'Comercio / Tienda', prefixIcon: Icon(Icons.storefront)),
                validator: (val) => val!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Precio (sin símbolo)', prefixIcon: Icon(Icons.attach_money)),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (val) => val!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Categoría (ej. Tecnología, Ropa)', prefixIcon: Icon(Icons.category)),
                validator: (val) => val!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveTicket,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
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
                          : const Text('GUARDAR TICKET')
                    ),
                  )
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
