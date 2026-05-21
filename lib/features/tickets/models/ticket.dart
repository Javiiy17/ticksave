import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/*
 * ¿Qué hace este archivo?
 * Aquí es donde definimos qué es exactamente un "Ticket" para nuestra aplicación.
 * Javi y yo hemos creado esta clase para moldear los datos que vienen de la base de datos
 * y convertirlos en objetos que podamos usar fácilmente en Flutter. Básicamente es el molde 
 * de nuestros tickets de compra, para que no falte ni un solo dato.
 */
class Ticket {
  Ticket({
    this.id,
    this.idUsuario,
    required this.nombreComercio,
    required this.precio,
    required this.fechaCompra,
    required this.urlImagen,
    this.categoria = 'General',
    this.codigoEscaneado,
    this.formatoCodigo,
  });

  String? id;
  String? idUsuario;
  String nombreComercio;
  String precio;
  DateTime fechaCompra;
  String urlImagen;
  String categoria;
  String? codigoEscaneado;
  String? formatoCodigo;

  // Calculamos cuándo se acaba la garantía. Por ley suelen ser 3 años desde que lo compras.
  DateTime get fechaGarantia {
    return DateTime(
      fechaCompra.year + 3,
      fechaCompra.month,
      fechaCompra.day,
    );
  }

  // Comprobamos si la garantía está a puntito de caducar (menos de 30 días).
  bool get estaApuntoDeCaducar {
    final ahora = DateTime.now();
    final diferenciaDias = fechaGarantia.difference(ahora).inDays;
    return diferenciaDias >= 0 && diferenciaDias <= 30;
  }
  
  // Para mostrar la fecha bonita en la pantalla (día/mes/año).
  String get fechaFormateada {
    return DateFormat('dd/MM/yyyy').format(fechaCompra);
  }

  // Esta función coge los datos en bruto de Firebase (que vienen como un diccionario o mapa)
  // y nos los transforma en un objeto Ticket de verdad.
  factory Ticket.desdeMapa(Map<String, dynamic> datos, String idDocumento) {
    return Ticket(
      id: idDocumento,
      // Ojo: el key 'userId' se queda en inglés porque así está guardado en Firebase
      idUsuario: datos['userId'] as String?,
      nombreComercio: datos['comercio'] as String? ?? 'Desconocido',
      precio: datos['precio'] as String? ?? '0 €',
      fechaCompra: datos['fecha_compra'] != null 
          ? (datos['fecha_compra'] as Timestamp).toDate() 
          : DateTime.now(),
      urlImagen: datos['url_imagen'] as String? ?? '',
      categoria: datos['categoria'] as String? ?? 'General',
      codigoEscaneado: datos['codigo_escaneado'] as String?,
      formatoCodigo: datos['formato_codigo'] as String?,
    );
  }

  // Y esta hace lo contrario: coge nuestro objeto Ticket y lo convierte en un mapa
  // para que Firebase se lo pueda tragar sin problemas.
  Map<String, dynamic> aMapa() {
    return {
      'userId': idUsuario, // Mantenemos el key original en inglés para Firebase
      'comercio': nombreComercio,
      'precio': precio,
      'fecha_compra': Timestamp.fromDate(fechaCompra),
      'fecha_garantia': Timestamp.fromDate(fechaGarantia),
      'url_imagen': urlImagen,
      'categoria': categoria,
      'codigo_escaneado': codigoEscaneado,
      'formato_codigo': formatoCodigo,
      'modificado_en': FieldValue.serverTimestamp(),
    };
  }
}
