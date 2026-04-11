import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Modelo de datos que representa un Ticket de compra individual.
/// Administra la conversión de datos y la lógica de fechas y garantías.
/// @author Javier Abellán
class Ticket {
  Ticket({
    this.id,
    this.userId,
    required this.storeName,
    required this.price,
    required this.purchaseDate,
    required this.imageUrl,
    this.categoria = 'General',
    this.scannedCode,
    this.barcodeFormat,
  });

  String? id;
  String? userId;
  String storeName;
  String price;
  DateTime purchaseDate;
  String imageUrl;
  String categoria;
  String? scannedCode;
  String? barcodeFormat;

  /// Devuelve la fecha de fin de garantía (3 años después de la compra)
  DateTime get expirationDate {
    return DateTime(
      purchaseDate.year + 3,
      purchaseDate.month,
      purchaseDate.day,
    );
  }

  /// Devuelve true si la garantía expira en menos de 30 días respecto a hoy
  bool get isExpiringSoon {
    final now = DateTime.now();
    final difference = expirationDate.difference(now).inDays;
    return difference >= 0 && difference <= 30;
  }
  
  /// Formateo amigable de la fecha
  String get formattedDate {
    return DateFormat('dd/MM/yyyy').format(purchaseDate);
  }

  /// Crea un objeto a partir del documento de Firebase
  factory Ticket.fromMap(Map<String, dynamic> data, String documentId) {
    return Ticket(
      id: documentId,
      userId: data['userId'] as String?,
      storeName: data['comercio'] as String? ?? 'Desconocido',
      price: data['precio'] as String? ?? '0 €',
      purchaseDate: data['fecha_compra'] != null 
          ? (data['fecha_compra'] as Timestamp).toDate() 
          : DateTime.now(),
      imageUrl: data['url_imagen'] as String? ?? '',
      categoria: data['categoria'] as String? ?? 'General',
      scannedCode: data['codigo_escaneado'] as String?,
      barcodeFormat: data['formato_codigo'] as String?,
    );
  }

  /// Pasa este objeto a un mapa para guardarlo en Firebase
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'comercio': storeName,
      'precio': price,
      'fecha_compra': Timestamp.fromDate(purchaseDate),
      'fecha_garantia': Timestamp.fromDate(expirationDate),
      'url_imagen': imageUrl,
      'categoria': categoria,
      'codigo_escaneado': scannedCode,
      'formato_codigo': barcodeFormat,
      'modificado_en': FieldValue.serverTimestamp(),
    };
  }
}
