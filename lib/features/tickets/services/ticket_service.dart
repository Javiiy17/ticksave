import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';

import '../models/ticket.dart';

class TicketService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream de tickets de un usuario
  Stream<List<Ticket>> getUserTickets() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('tickets')
        .orderBy('fecha_compra', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Ticket.fromMap(doc.data(), doc.id)).toList();
    });
  }

  /// Agrega un nuevo ticket
  Future<void> addTicket(Ticket ticket) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    ticket.userId = user.uid; // Safety: force link to current user
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('tickets')
        .add(ticket.toMap());
  }

  /// Actualiza un ticket existente
  Future<void> updateTicket(Ticket ticket) async {
    final user = _auth.currentUser;
    if (user == null || ticket.id == null) return;
    
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('tickets')
        .doc(ticket.id)
        .update(ticket.toMap());
  }
  
  /// Elimina un ticket
  Future<void> deleteTicket(String ticketId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('tickets')
        .doc(ticketId)
        .delete();
  }

  /// Comprime una imagen y la sube a Firebase Storage. Devuelve la URL de descarga.
  Future<String?> uploadTicketImage(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      // Comprimir imagen
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.absolute.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';
      
      final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path, 
        targetPath,
        quality: 70,
        minWidth: 800,
      );

      if (compressedFile == null) return null;

      // Subir a Storage
      final fileName = 'tickets/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(fileName);
      
      final uploadTask = await ref.putFile(File(compressedFile.path));
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      // ignore: avoid_print
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Procesa una imagen con ML Kit y extrae un texto tentativo (ej. Fecha y Comercio).
  Future<Map<String, String>> extractTicketData(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    
    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      String possibleStore = "Desconocido";
      String possibleDate = "Hoy";
      
      // Regex para buscar fechas (ej. 12/03/2026, 12-03-2026, 12/03/26)
      RegExp datePattern =  RegExp(r'\b\d{1,2}[/-]\d{1,2}[/-]\d{2,4}\b');
      
      // La primera línea grande o bloque superior suele ser la tienda
      if (recognizedText.blocks.isNotEmpty) {
        // Tomamos el primer bloque de texto no vacío como la tienda
        final firstBlock = recognizedText.blocks.first.text.replaceAll('\n', ' ').trim();
        if (firstBlock.isNotEmpty && firstBlock.length > 2) {
            possibleStore = firstBlock;
        }
      }

      // Buscar si hay una fecha
      final String fullText = recognizedText.text;
      final match = datePattern.firstMatch(fullText);
      if (match != null) {
        possibleDate = match.group(0) ?? "Hoy";
      }

      return {
        'storeName': possibleStore,
        'date': possibleDate,
      };

    } finally {
      textRecognizer.close();
    }
  }
}
