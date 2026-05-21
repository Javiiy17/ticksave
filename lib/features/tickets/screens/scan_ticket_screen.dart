import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/ticket_service.dart';
import 'edit_ticket_screen.dart';

/*
 * ¿Qué hace este archivo?
 * Aquí abrimos la cámara normal del móvil para tirarle una foto al ticket físico.
 * Luego le pasamos esa foto al servicio ML Kit de Firebase, que lee las letras 
 * como si fuera magia, y nos autocompleta el nombre de la tienda, precio y fecha 
 * en la pantalla de editar. 
 */
class PantallaEscanearTicket extends StatefulWidget {
  const PantallaEscanearTicket({super.key});

  @override
  State<PantallaEscanearTicket> createState() => _EstadoPantallaEscanearTicket();
}

class _EstadoPantallaEscanearTicket extends State<PantallaEscanearTicket> {
  final ServicioTicket _servicioTicket = ServicioTicket();
  final ImagePicker _selectorImagen = ImagePicker();

  bool _procesando = false;
  File? _archivoImagen;

  // Abre la cámara, echa la foto, la sube para leer las letras, y te lleva al formulario
  Future<void> _tomarFotoYProcesar() async {
    try {
      final XFile? foto = await _selectorImagen.pickImage(source: ImageSource.camera);
      if (foto == null) return;

      setState(() {
        _archivoImagen = File(foto.path);
        _procesando = true; // Sacamos la ruedita de carga para que el usuario sepa que la app está pensando
      });

      // Extraer datos leyendo el texto de la foto con IA (OCR)
      final datosLeidos = await _servicioTicket.extraerDatosTicket(_archivoImagen!);

      if (!mounted) return;

      // Vamos al formulario de editar y le pasamos todo lo que ha adivinado la IA
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (context) => PantallaEditarTicket(
            nombreComercioEscaneado: datosLeidos['nombreComercio'],
            fechaEscaneada: datosLeidos['date'],
            precioInicial: datosLeidos['price'],
            nuevoArchivoImagen: _archivoImagen,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error al capturar o leer el ticket con OCR: $e');
      if (mounted) {
        setState(() => _procesando = false);
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
             content: Text('Error al procesar el ticket. Prueba de nuevo.', style: TextStyle(color: Colors.white)), 
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
        child: _procesando 
          ? _construirVistaProcesando() // Si está la IA leyendo...
          : _construirVistaInstrucciones(), // Si aún no hemos hecho foto...
      ),
      floatingActionButton: _procesando 
        ? null 
        : FloatingActionButton.extended(
            onPressed: _tomarFotoYProcesar,
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

  // Texto explicativo en medio de la pantalla
  Widget _construirVistaInstrucciones() {
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

  // Pantalla de carga mientras la IA "lee" el ticket
  Widget _construirVistaProcesando() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_archivoImagen != null)
           Padding(
             padding: const EdgeInsets.only(bottom: 30),
             child: ClipRRect(
               borderRadius: BorderRadius.circular(16),
               child: Image.file(_archivoImagen!, height: 300, fit: BoxFit.cover),
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
