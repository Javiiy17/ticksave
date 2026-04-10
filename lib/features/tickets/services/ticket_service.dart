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

  /// Devuelve los tickets del usuario logueado en tiempo real =O
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

  /// Sube un ticket nuevo a la bdd de Firebase
  Future<void> addTicket(Ticket ticket) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    ticket.userId = user.uid; // Por si acaso, forzamos que el ticket se asocie al ID del usuario
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('tickets')
        .add(ticket.toMap());
  }

  /// Sobreescribe los datos de un ticket
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
  
  /// Se carga el ticket y lo borra
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

  /// Comprimimos un pelín la foto antes de mandarla al Storage para que no tarde mil años
  Future<String?> uploadTicketImage(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      // A comprimir toca
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.absolute.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';
      
      final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path, 
        targetPath,
        quality: 70,
        minWidth: 800,
      );

      if (compressedFile == null) return null;

      // A la nube con todo
      final fileName = 'tickets/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(fileName);
      
      final uploadTask = await ref.putFile(File(compressedFile.path));
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      // Si esto falla lo ignoramos por no petar la app entera, pero malo jaja
      // ignore: avoid_print
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Usamos IA (ML Kit) para adivinar el texto de la foto y sacar fecha y tienda
  Future<Map<String, String>> extractTicketData(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    
    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      String possibleStore = "Desconocido";
      String possibleDate = "Hoy";
      
      // Patter loco de regex para fechas (12/03/2026, etc)
      RegExp datePattern =  RegExp(r'\b\d{1,2}[/-]\d{1,2}[/-]\d{2,4}\b');
      
      // Normalmente lo primerito en el ticket arriba del todo es el nombre
      if (recognizedText.blocks.isNotEmpty) {
        // Cogemos el primer bloque de texto
        final firstBlock = recognizedText.blocks.first.text.replaceAll('\n', ' ').trim();
        if (firstBlock.isNotEmpty && firstBlock.length > 2) {
            possibleStore = firstBlock;
        }
      }

      // Pasamos a buscar la fecha a ver si hay suerte
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
