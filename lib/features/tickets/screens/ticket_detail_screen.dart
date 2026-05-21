import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/settings/app_settings_scope.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/utils/price_currency.dart';
import '../../../core/utils/raster_image_url.dart';
import '../models/ticket.dart';
import '../services/ticket_service.dart';
import 'alert_screen.dart';
import 'edit_ticket_screen.dart';

/*
 * ¿Qué hace este archivo?
 * Cuando pulsas encima de un ticket, se abre esta pantalla enorme. 
 * Aquí ves la foto del recibo en grande, cuánto te costó, si tienes alarma puesta 
 * y te dejamos botoncitos para compartirlo por WhatsApp, editarlo si hay algún fallo, o borrarlo.
 */
class PantallaDetalleTicket extends StatefulWidget {
  const PantallaDetalleTicket({
    super.key,
    required this.ticket,
    this.codigoEscaneado,
    this.etiquetaFormatoCodigo,
    this.ticketOrigen,
    this.indiceLineaOrigen = 0,
  });

  final Ticket ticket;

  // Valor que pillamos del código QR o de barras si vienes de la cámara
  final String? codigoEscaneado;

  // Tipo de código (por ejemplo, 'EAN-13' o 'QR')
  final String? etiquetaFormatoCodigo;

  // El ticket original por si hacemos cambios, no fastidiarlo
  final Ticket? ticketOrigen;

  // Una cosilla técnica para saber en qué parte de la lista estaba
  final int indiceLineaOrigen;

  @override
  State<PantallaDetalleTicket> createState() => _EstadoPantallaDetalleTicket();
}

class _EstadoPantallaDetalleTicket extends State<PantallaDetalleTicket> {
  late String _nombreComercio;
  late String _fecha;
  late String _precio;
  late String _urlImagen;
  late String _categoria;
  String? _codigoEscaneado;
  String? _etiquetaFormatoCodigo;

  @override
  void initState() {
    super.initState();
    // Pillamos los datos iniciales al abrir la pantalla
    _nombreComercio = widget.ticket.nombreComercio;
    _fecha = widget.ticket.fechaFormateada;
    _precio = widget.ticket.precio;
    _urlImagen = widget.ticket.urlImagen;
    _categoria = widget.ticket.categoria;
    _codigoEscaneado = widget.ticket.codigoEscaneado ?? widget.codigoEscaneado;
    _etiquetaFormatoCodigo = widget.ticket.formatoCodigo ?? widget.etiquetaFormatoCodigo;
  }

  // Vamos a la pantalla de crear la alarma en el calendario
  void _abrirPantallaAlerta() {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => PantallaAlerta(
          nombreComercio: _nombreComercio,
          fechaCompra: _fecha,
        ),
      ),
    );
  }

  // Si algún dato se ha leído mal del ticket, nos vamos a editarlo
  Future<void> _abrirEditarTicket() async {
    final resultado = await Navigator.push<ResultadoEditarTicket>(
      context,
      MaterialPageRoute<ResultadoEditarTicket>(
        builder: (context) => PantallaEditarTicket( // Luego traducimos esta pantalla a PantallaEditarTicket
          nombreComercioInicial: _nombreComercio,
          fechaInicial: _fecha,
          precioInicial: _precio,
          codigoEscaneado: _codigoEscaneado,
          formatoCodigoBarras: _etiquetaFormatoCodigo,
        ),
      ),
    );

    if (!mounted || resultado == null) return;

    // Cuando volvamos, actualizamos la vista con lo que haya cambiado el usuario
    setState(() {
      _nombreComercio = resultado.nombreComercio;
      _fecha = resultado.fecha;
      _precio = resultado.precio;
    });

    // Actualizamos el ticket de verdad y lo mandamos a Firebase a la velocidad de la luz
    final ticketActualizar = widget.ticketOrigen ?? (widget.ticket.id != null ? widget.ticket : null);
    if (ticketActualizar != null) {
      ticketActualizar.nombreComercio = _nombreComercio;
      ticketActualizar.precio = _precio;
      
      await ServicioTicket().actualizarTicket(ticketActualizar);
    }
  }

  // ¡A tomar por saco el ticket!
  Future<void> _eliminarTicket() async {
    final textos = TextosApp.de(context);
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF140A26),
        title: Text(textos.tituloConfirmarEliminarTicket, style: const TextStyle(color: Colors.white)),
        content: Text(textos.cuerpoConfirmarEliminarTicket, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(textos.cancelar, style: const TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: Text(textos.borrar, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmacion == true) {
      if (widget.ticket.id != null) {
        await ServicioTicket().eliminarTicket(widget.ticket.id!);
      }
      if (mounted) Navigator.pop(context, true); // Cerramos y avisamos de que lo hemos borrado
    }
  }

  // Compartir mola. Generamos la foto, el QR, y se lo mandamos a un colega por WhatsApp.
  Future<void> _compartirTicket() async {
    final textos = TextosApp.de(context);
    final mensaje = textos.mensajeCompartirTicket(_nombreComercio, _fecha, _precio, codigo: _codigoEscaneado);
    
    List<XFile> archivosACompartir = [];
    
    try {
      final directorioTemp = await getTemporaryDirectory();

      // 1. Descargamos la imagen física del ticket
      if (_urlImagen.isNotEmpty && _urlImagen.startsWith('http')) {
        final respuesta = await http.get(Uri.parse(urlRasterHttpOPlaceholder(_urlImagen)));
        if (respuesta.statusCode == 200) {
          final archivo = File('${directorioTemp.path}/ticket_share.jpg');
          await archivo.writeAsBytes(respuesta.bodyBytes);
          archivosACompartir.add(XFile(archivo.path));
        }
      }

      // 2. Si tenía un código escaneado, le generamos la foto del QR/Barras al vuelo usando una API gratis
      if (_codigoEscaneado != null && _codigoEscaneado!.isNotEmpty) {
        final esQr = _etiquetaFormatoCodigo?.toLowerCase().contains('qr') == true;
        final urlCodigo = esQr 
            ? 'https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=$_codigoEscaneado'
            : 'https://barcodeapi.org/api/128/$_codigoEscaneado';
            
        final respuestaCodigo = await http.get(Uri.parse(urlCodigo));
        if (respuestaCodigo.statusCode == 200) {
          final archivoCodigo = File('${directorioTemp.path}/code_share.png');
          await archivoCodigo.writeAsBytes(respuestaCodigo.bodyBytes);
          archivosACompartir.add(XFile(archivoCodigo.path));
        }
      }
    } catch (e) {
      // Si explota el internet, mandamos el texto solo y listo.
    }
    
    if (archivosACompartir.isNotEmpty) {
      await Share.shareXFiles(archivosACompartir, text: mensaje);
    } else {
      await Share.share(mensaje);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = TextosApp.de(context);

    return Scaffold(
      backgroundColor: const Color(0xFF090310),
      appBar: AppBar(
        title: Text(
          textos.tituloDetalleTicket,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Si el ticket se leyó por escáner, enseñamos el dibujo del código. Si no, la foto del ticket físico
            if (_codigoEscaneado != null && _codigoEscaneado!.isNotEmpty)
              _construirVisorCodigoBarras()
            else
              _construirImagenCabecera(),
            const SizedBox(height: 20),
            _construirTarjetaInformacion(),
            const SizedBox(height: 20),
            _construirSeccionGarantia(),
            const SizedBox(height: 30),
            _construirBotones(context),
          ],
        ),
      ),
    );
  }

  // La foto bonita de la cabecera
  Widget _construirImagenCabecera() {
    if (_urlImagen.isEmpty) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF140A26),
          borderRadius: BorderRadius.circular(25),
        ),
        child: const Center(
          child: Icon(Icons.receipt_long, size: 80, color: Colors.white54),
        ),
      );
    }
    
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        image: DecorationImage(
          image: NetworkImage(urlRasterHttpOPlaceholder(_urlImagen)),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF4081).withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
    );
  }

  // Dibuja el código de barras o QR para que la gente de la caja del súper lo pueda escanear de la pantalla
  Widget _construirVisorCodigoBarras() {
    if (_codigoEscaneado == null || _codigoEscaneado!.isEmpty) return const SizedBox.shrink();

    final esQr = _etiquetaFormatoCodigo?.toLowerCase().contains('qr') == true;
    final url = esQr 
        ? 'https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=$_codigoEscaneado'
        : 'https://barcodeapi.org/api/128/$_codigoEscaneado';

    return GestureDetector(
      onTap: () {
        // Al tocarlo, se hace gigante en medio de la pantalla
        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    esQr ? 'Escaneando QR' : 'Escaneando Barras',
                    style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 25),
                  Image.network(url, fit: BoxFit.contain, height: 250),
                  const SizedBox(height: 20),
                  Text(_codigoEscaneado!, style: const TextStyle(color: Colors.black54, fontSize: 18, letterSpacing: 2)),
                ],
              ),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          children: [
            Image.network(url, height: 90, fit: BoxFit.contain),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.zoom_out_map, color: Colors.grey.shade600, size: 16),
                const SizedBox(width: 8),
                Text(
                  TextosApp.de(context).tocarParaAmpliar,
                  style: const TextStyle(color: Colors.black45, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // La cajita negra de en medio con los textos y precios
  Widget _construirTarjetaInformacion() {
    final textos = TextosApp.de(context);
    final bool tieneCodigo = _codigoEscaneado != null && _codigoEscaneado!.isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF140A26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _nombreComercio,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                ),
              ),
              if (_categoria.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFE91E63).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                  child: Text(_categoria, style: const TextStyle(color: Color(0xFFE91E63), fontSize: 12, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          if (tieneCodigo) ...[
            const SizedBox(height: 15),
            const Divider(color: Colors.white12),
            const SizedBox(height: 15),
            _FilaInformacion(icono: Icons.qr_code, colorIcono: Colors.deepOrange, titulo: textos.codigoLeido, valor: _codigoEscaneado!),
            _FilaInformacion(icono: Icons.loyalty, colorIcono: Colors.teal, titulo: textos.formatoCodigo, valor: _etiquetaFormatoCodigo ?? textos.formatoDesconocido),
          ],
          const SizedBox(height: 15),
          const Divider(color: Colors.white12),
          const SizedBox(height: 15),
          _FilaInformacion(icono: Icons.calendar_today, colorIcono: Colors.greenAccent, titulo: textos.fechaCompra, valor: _fecha),
          const Divider(color: Colors.white12, height: 30),
          _FilaInformacion(icono: Icons.monetization_on, colorIcono: const Color(0xFFFF4081), titulo: textos.importeTicket, valor: DivisaPrecio.formatearParaVista(_precio, AlcanceAjustesApp.of(context).simboloMoneda), colorValor: const Color(0xFFFF4081), esNegrita: true, esGrande: true),
        ],
      ),
    );
  }

  // La tira de colores de abajo para activar la garantía en el calendario
  Widget _construirSeccionGarantia() {
    final textos = TextosApp.de(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFE91E63), Color(0xFF9C27B0)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.security, color: Colors.white, size: 28),
              const SizedBox(width: 10),
              Text(textos.protegerGarantia, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Text(textos.pistaAlertaGarantia, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: _abrirPantallaAlerta,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF9C27B0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(textos.configurarAlerta),
          )
        ],
      ),
    );
  }

  // Los 3 botones de abajo
  Widget _construirBotones(BuildContext context) {
    final textos = TextosApp.de(context);
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 55,
          child: OutlinedButton.icon(
            onPressed: _compartirTicket,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blueAccent,
              side: const BorderSide(color: Colors.blueAccent),
            ),
            icon: const Icon(Icons.share_outlined),
            label: Text(textos.compartirTicket),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: OutlinedButton.icon(
            onPressed: _abrirEditarTicket,
            icon: const Icon(Icons.edit_outlined),
            label: Text(textos.editarTicket),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: OutlinedButton.icon(
            onPressed: _eliminarTicket,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent),
            ),
            icon: const Icon(Icons.delete_outline),
            label: Text(textos.eliminarTicket),
          ),
        ),
      ],
    );
  }
}

// Un widget pequeño para dibujar filas con icono bonito (precio, fecha...)
class _FilaInformacion extends StatelessWidget {
  const _FilaInformacion({
    required this.icono,
    required this.colorIcono,
    required this.titulo,
    required this.valor,
    this.colorValor,
    this.esNegrita = false,
    this.esGrande = false,
  });

  final IconData icono;
  final Color colorIcono;
  final String titulo;
  final String valor;
  final Color? colorValor;
  final bool esNegrita;
  final bool esGrande;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorIcono.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icono, color: colorIcono, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                valor,
                style: TextStyle(
                  color: colorValor ?? Colors.white,
                  fontWeight: esNegrita ? FontWeight.bold : FontWeight.normal,
                  fontSize: esGrande ? 20 : 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
