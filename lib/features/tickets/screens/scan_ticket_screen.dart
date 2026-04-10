import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/ticket_service.dart';
import 'edit_ticket_screen.dart';

/// Pantalla encargada de sacar foto al ticket e intentar extraer datos con OCR.
class ScanTicketScreen extends StatefulWidget {
  const ScanTicketScreen({super.key});

  @override
  State<ScanTicketScreen> createState() => _ScanTicketScreenState();
}

class _ScanTicketScreenState extends State<ScanTicketScreen> {
  final TicketService _ticketService = TicketService();
  final ImagePicker _picker = ImagePicker();

  bool _isProcessing = false;
  File? _imageFile;

  /// Abre la cámara, toma la foto y la procesa con ML Kit (OCR)
  Future<void> _takePhotoAndProcess() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo == null) return;

      setState(() {
        _imageFile = File(photo.path);
        _isProcessing = true;
      });

      // Extraer datos con el OCR del servicio
      final data = await _ticketService.extractTicketData(_imageFile!);

      if (!mounted) return;

      // Navegar a la pantalla de edición pasándole los datos extraídos
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (context) => EditTicketScreen(
            scannedStoreName: data['storeName'],
            scannedDate: data['date'],
            newImageFile: _imageFile,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error al capturar/procesar OCR: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
             content: Text('Error al procesar el ticket. Prueba de nuevo.'), 
             backgroundColor: Colors.redAccent,
             behavior: SnackBarBehavior.floating,
           ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Escanear Ticket',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: false,
        elevation: 0,
      ),
      body: Center(
        child: _isProcessing 
          ? _buildProcessingView() 
          : _buildInstructionView(),
      ),
      floatingActionButton: _isProcessing 
        ? null 
        : FloatingActionButton.extended(
            onPressed: _takePhotoAndProcess,
            backgroundColor: const Color(0xFFE91E63),
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            label: const Text(
              'Tomar Foto', 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.1)
            ),
          ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildInstructionView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.receipt_long_outlined, size: 100, color: Colors.white54),
        SizedBox(height: 20),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Pulsa "Tomar Foto" y apunta bien iluminado a tu ticket para extraer automáticamente el comercio y la fecha de compra mediante IA.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_imageFile != null)
           Padding(
             padding: const EdgeInsets.only(bottom: 30),
             child: ClipRRect(
               borderRadius: BorderRadius.circular(16),
               child: Image.file(_imageFile!, height: 300, fit: BoxFit.cover),
             ),
           ),
        const CircularProgressIndicator(
          color: Color(0xFFE91E63),
          strokeWidth: 4,
        ),
        const SizedBox(height: 20),
        const Text(
          'Analizando ticket con Inteligencia Artificial...',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}


