import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';

import '../models/ticket.dart';

/*
 * Aquí es donde cocinamos todo el tema de la base de datos de los tickets y el escáner de fotos.
 * Básicamente, esta clase nos permite conectar nuestra app con Firestore (para guardar el texto),
 * con Firebase Storage (para subir las fotos sin que explote) y con Google ML Kit, que es la IA
 * que lee el texto de las imágenes
 */
class ServicioTicket {
  final FirebaseStorage _almacenamiento = FirebaseStorage.instance;
  final FirebaseAuth _autenticacion = FirebaseAuth.instance;
  final FirebaseFirestore _baseDatos = FirebaseFirestore.instance;

  // Devuelve un stream de los tickets del usuario logueado, en tiempo real
  Stream<List<Ticket>> obtenerTicketsUsuario() {
    final usuario = _autenticacion.currentUser;
    if (usuario == null) return Stream.value([]);
    
    return _baseDatos
        .collection('users')
        .doc(usuario.uid)
        .collection('tickets')
        .orderBy('fecha_compra', descending: true)
        .snapshots()
        .map((instantanea) {
      return instantanea.docs.map((doc) => Ticket.desdeMapa(doc.data(), doc.id)).toList();
    });
  }

  // Sube un ticket nuevecito a la base de datos de Firebase
  Future<void> anadirTicket(Ticket ticket) async {
    final usuario = _autenticacion.currentUser;
    if (usuario == null) return;
    
    // Asocia el ticket al ID de nuestro usuario actual
    ticket.idUsuario = usuario.uid;
    await _baseDatos
        .collection('users')
        .doc(usuario.uid)
        .collection('tickets')
        .add(ticket.aMapa())
        .timeout(const Duration(seconds: 10));
  }

  // Sobrescribe y actualiza los datos de un ticket que ya teníamos
  Future<void> actualizarTicket(Ticket ticket) async {
    final usuario = _autenticacion.currentUser;
    if (usuario == null || ticket.id == null) return;
    
    await _baseDatos
        .collection('users')
        .doc(usuario.uid)
        .collection('tickets')
        .doc(ticket.id)
        .update(ticket.aMapa())
        .timeout(const Duration(seconds: 10));
  }
  
  // Elimina un ticket
  Future<void> eliminarTicket(String idTicket) async {
    final usuario = _autenticacion.currentUser;
    if (usuario == null) return;
    
    await _baseDatos
        .collection('users')
        .doc(usuario.uid)
        .collection('tickets')
        .doc(idTicket)
        .delete();
  }

  // Comprime la foto antes de mandarla al Storage para que no tarde mil años y no gaste megas tontamente
  Future<String?> subirImagenTicket(File archivoImagen) async {
    try {
      final usuario = _autenticacion.currentUser;
      if (usuario == null) return null;

      // Comprime la imagen
      final directorio = await getTemporaryDirectory();
      final rutaDestino = '${directorio.absolute.path}/${DateTime.now().millisecondsSinceEpoch}_comprimido.jpg';
      
      final XFile? archivoComprimido = await FlutterImageCompress.compressAndGetFile(
        archivoImagen.absolute.path, 
        rutaDestino,
        quality: 70,
        minWidth: 800,
      );

      if (archivoComprimido == null) return null;

      // Sube la imagen a Firebase Storage
      final nombreArchivo = 'tickets/${usuario.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final referencia = _almacenamiento.ref().child(nombreArchivo);
      
      final tareaSubida = await referencia.putFile(File(archivoComprimido.path));
      final urlDescarga = await tareaSubida.ref.getDownloadURL();
      
      return urlDescarga;
    } catch (e) {
      // Si esto falla lo ignoramos por no petar la app entera
      // ignore: avoid_print
      print('Error al subir la imagen: $e');
      return null;
    }
  } 

  // Usa ML Kit para leer el texto de la foto y sacar el comercio, la pasta y la fecha
  Future<Map<String, String>> extraerDatosTicket(File archivoImagen) async {
    final imagenEntrada = InputImage.fromFile(archivoImagen);
    final reconocedorTexto = TextRecognizer(script: TextRecognitionScript.latin);
    
    try {
      final RecognizedText textoReconocido = await reconocedorTexto.processImage(imagenEntrada);
      
      String posibleComercio = "Desconocido";
      String posibleFecha = "Hoy";
      String posiblePrecio = "";
      
      // Expresión regular para pillar fechas tipo 12/03/2026 o 12-03-26
      RegExp patronFecha =  RegExp(r'\b\d{1,2}[/-]\d{1,2}[/-]\d{2,4}\b');
      // Expresión regular para pillar el dinero: '15,50' o '15.50'
      RegExp patronPrecio = RegExp(r'\b\d+[,.]\d{2}\b');
      
      // El primer bloque de texto suele ser el nombre de la tienda
      if (textoReconocido.blocks.isNotEmpty) {
        // Cogemos el primer bloque de texto y lo limpiamos
        final primerBloque = textoReconocido.blocks.first.text.replaceAll('\n', ' ').trim();
        if (primerBloque.isNotEmpty && primerBloque.length > 2) {
            posibleComercio = primerBloque;
        }
      }

      // Buscamos la fecha con la expresión regular
      final String textoEntero = textoReconocido.text;
      final matchFecha = patronFecha.firstMatch(textoEntero);
      if (matchFecha != null) {
        posibleFecha = matchFecha.group(0) ?? "Hoy";
      }

      // Buscamos los precios con la expresión regular
      final matchesPrecio = patronPrecio.allMatches(textoEntero);
      if (matchesPrecio.isNotEmpty) {
        posiblePrecio = matchesPrecio.last.group(0) ?? "";
      }

      return {
        'nombreComercio': posibleComercio,
        'fecha': posibleFecha,
        'precio': posiblePrecio,
      };

    } finally {
      reconocedorTexto.close();
    }
  }
}
