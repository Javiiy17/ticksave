import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/ticket.dart';
import '../services/ticket_service.dart';
import '../../home/screens/home_screen.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/settings/app_settings_scope.dart';
import '../../../core/utils/price_currency.dart';

/*
 * ¿Qué hace este archivo?
 * Cuando le damos a editar un ticket desde el detalle, nos devuelve esto 
 * con los datos nuevos que ha escrito el usuario, para refrescar la pantalla.
 */
class ResultadoEditarTicket {
  const ResultadoEditarTicket({
    required this.nombreComercio,
    required this.fecha,
    required this.precio,
  });

  final String nombreComercio;
  final String fecha;
  final String precio;
}

/*
 * ¿Qué hace este archivo?
 * Este es el pedazo de formulario donde creas un ticket a mano o editas uno viejo.
 * Está hecho para que valga tanto si vienes de escribirlo tú letra a letra 
 * como si vienes de la cámara y la IA ya ha rellenado la mitad de las cosas.
 */
class PantallaEditarTicket extends StatefulWidget {
  final Ticket? ticketExistente;
  final String? nombreComercioEscaneado;
  final String? fechaEscaneada;
  final String? precioInicial;
  final File? nuevoArchivoImagen;
  final String? codigoEscaneado;
  final String? formatoCodigoBarras;

  // Constructor multiusos: sirve para el flujo de la cámara o para editar desde el detalle.
  const PantallaEditarTicket({
    super.key,
    this.ticketExistente,
    this.nombreComercioEscaneado,
    this.fechaEscaneada,
    this.precioInicial,
    this.nuevoArchivoImagen,
    this.codigoEscaneado,
    this.formatoCodigoBarras,
    // Estas dos variables son para no romper el código que hizo Javi en el detalle
    String? nombreComercioInicial,
    String? fechaInicial,
  }) : 
    _compatStoreName = nombreComercioInicial,
    _compatDate = fechaInicial;

  final String? _compatStoreName;
  final String? _compatDate;

  @override
  State<PantallaEditarTicket> createState() => _EstadoPantallaEditarTicket();
}

class _EstadoPantallaEditarTicket extends State<PantallaEditarTicket> {
  final ServicioTicket _servicioTicket = ServicioTicket();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _controladorComercio;
  late TextEditingController _controladorPrecio;
  late TextEditingController _controladorCategoria;
  late TextEditingController _controladorFecha;
  late TextEditingController _controladorCodigoEscaneado;
  
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    // Metemos en los cajones de texto lo que ya sepamos (del ticket viejo o de la IA de la cámara)
    _controladorComercio = TextEditingController(
      text: widget.ticketExistente?.nombreComercio ?? 
            widget.nombreComercioEscaneado ?? 
            widget._compatStoreName ?? ''
    );
    _controladorPrecio = TextEditingController(
      text: widget.ticketExistente?.precio != null 
            ? DivisaPrecio.quitarSufijosConocidos(widget.ticketExistente!.precio) 
            : (widget.precioInicial != null ? DivisaPrecio.quitarSufijosConocidos(widget.precioInicial!) : '')
    );
    _controladorCategoria = TextEditingController(
      text: widget.ticketExistente?.categoria ?? 'General'
    );
    _controladorFecha = TextEditingController(
      text: widget.ticketExistente?.fechaFormateada ?? 
            widget.fechaEscaneada ?? 
            widget._compatDate ?? ''
    );
    _controladorCodigoEscaneado = TextEditingController(
      text: widget.ticketExistente?.codigoEscaneado ?? widget.codigoEscaneado ?? ''
    );
  }

  @override
  void dispose() {
    _controladorComercio.dispose();
    _controladorPrecio.dispose();
    _controladorCategoria.dispose();
    _controladorFecha.dispose();
    _controladorCodigoEscaneado.dispose();
    super.dispose();
  }

  // Cuando le damos a guardar comprobamos que no haya dejado campos vacíos
  Future<void> _manejarGuardado() async {
    if (!_formKey.currentState!.validate()) return;

    // Si venimos de la pantalla de detalle, le devolvemos los datos pa'tras
    if (widget.ticketExistente != null || widget._compatStoreName != null) {
       final simbolo = AlcanceAjustesApp.of(context).simboloMoneda;
       final precioConSimbolo = DivisaPrecio.conSimbolo(_controladorPrecio.text.trim(), simbolo);
       
       // Si el ticket ya existe en Firebase, lo machacamos con lo nuevo
       if (widget.ticketExistente != null && widget.ticketExistente!.id != null) {
          await _guardarEnFirebase();
       } else {
         // Si es solo devolver datos al compañero (flujo de Javi)
         Navigator.pop(
           context,
           ResultadoEditarTicket(
             nombreComercio: _controladorComercio.text.trim(),
             fecha: _controladorFecha.text.trim(),
             precio: precioConSimbolo,
           ),
         );
       }
    } else {
      // Si venimos del escáner y es un ticket nuevecito de paquete
      await _guardarEnFirebase();
    }
  }

  // Esto pilla todos los textos y los tira a la base de datos de Firebase
  Future<void> _guardarEnFirebase() async {
    setState(() => _cargando = true); // Ponemos la ruedita de cargar
    try {
      String urlImagen = widget.ticketExistente?.urlImagen ?? '';

      // Si le hemos hecho foto nueva, la subimos a Firebase Storage primero
      if (widget.nuevoArchivoImagen != null) {
        final url = await _servicioTicket.subirImagenTicket(widget.nuevoArchivoImagen!);
        if (url != null) urlImagen = url;
      }

      // Intentamos que la fecha esté bien, si no, le cascamos la de hoy
      DateTime fechaParseada;
      try {
        fechaParseada = DateFormat('dd/MM/yyyy').parse(_controladorFecha.text.trim());
      } catch (_) {
        fechaParseada = DateTime.now();
      }

      final datosTicketNuevo = Ticket(
        id: widget.ticketExistente?.id,
        nombreComercio: _controladorComercio.text.trim(),
        precio: '${_controladorPrecio.text.trim().replaceAll(',', '.')} €', 
        fechaCompra: fechaParseada,
        urlImagen: urlImagen,
        categoria: _controladorCategoria.text.trim(),
        codigoEscaneado: _controladorCodigoEscaneado.text.trim().isNotEmpty ? _controladorCodigoEscaneado.text.trim() : null,
        formatoCodigo: widget.ticketExistente?.formatoCodigo ?? widget.formatoCodigoBarras,
      );

      if (widget.ticketExistente == null) {
        // Creamos uno de cero
        await _servicioTicket.anadirTicket(datosTicketNuevo);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(TextosApp.de(context).ticketCreadoExito, style: const TextStyle(color: Colors.white)), 
            backgroundColor: Colors.green
          ),
        );
        // Nos piramos al menú principal del tirón y vaciamos el historial de navegación
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const PantallaInicio()),
          (Route<dynamic> route) => false,
        );
      } else {
        // Actualizamos el que ya había
        await _servicioTicket.actualizarTicket(datosTicketNuevo);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(TextosApp.de(context).ticketActualizadoExito, style: const TextStyle(color: Colors.white)), 
            backgroundColor: Colors.green
          ),
        );
        Navigator.pop(context, true); // Volvemos pa'tras
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().contains('Timeout') 
              ? 'Error: Falla la conexión con la base de datos' 
              : 'Error al guardar: $e', style: const TextStyle(color: Colors.white)), 
            backgroundColor: Colors.redAccent
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = TextosApp.de(context);
    final bool esEdicion = widget.ticketExistente != null || widget._compatStoreName != null;
    
    return Scaffold(
      backgroundColor: const Color(0xFF090310),
      appBar: AppBar(
        title: Text(esEdicion ? textos.tituloEditarTicket : textos.guardarNuevoTicket),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _construirPrevisualizacionImagen(),
              const SizedBox(height: 25),
              _construirCampoTexto(
                controlador: _controladorComercio,
                etiqueta: textos.etiquetaComercio,
                icono: Icons.storefront,
              ),
              const SizedBox(height: 20),
              _construirCampoTexto(
                controlador: _controladorFecha,
                etiqueta: textos.etiquetaFecha,
                icono: Icons.calendar_today,
                pista: 'dd/mm/aaaa',
                iconoExtra: IconButton(
                  icon: const Icon(Icons.today, color: Color(0xFFE91E63)),
                  onPressed: () {
                    // Botoncito rápido para poner la fecha de hoy
                    setState(() {
                      _controladorFecha.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              _construirCampoTexto(
                controlador: _controladorPrecio,
                etiqueta: textos.etiquetaPrecio,
                icono: Icons.attach_money,
                tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
                // Solo dejamos meter números y puntos/comas para que no pongan letras raras en el precio
                formateadores: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+[,.]?\d*')),
                ],
              ),
              const SizedBox(height: 20),
              _construirCampoTexto(
                controlador: _controladorCategoria,
                etiqueta: textos.categoria,
                icono: Icons.category,
              ),
              // Si veníamos de leer un QR o código de barras, enseñamos la tarjeta del código
              if (_controladorCodigoEscaneado.text.isNotEmpty || widget.formatoCodigoBarras != null) 
                _construirSeccionInfoCodigoBarras(),
              const SizedBox(height: 40),
              _construirBotonGuardar(),
            ],
          ),
        ),
      ),
    );
  }

  // Muestra una tarjetita con la info del código de barras que hemos escaneado
  Widget _construirSeccionInfoCodigoBarras() {
    final textos = TextosApp.de(context);
    final nombreFormato = widget.ticketExistente?.formatoCodigo ?? widget.formatoCodigoBarras ?? textos.formatoDesconocido;
    final esQr = nombreFormato.toLowerCase().contains('qr');
    final valorCodigo = _controladorCodigoEscaneado.text;
    
    // Si borran el código, escondemos la tarjeta
    if (valorCodigo.isEmpty) return const SizedBox.shrink();

    final url = esQr 
        ? 'https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=$valorCodigo'
        : 'https://barcodeapi.org/api/128/$valorCodigo';

    return Container(
      margin: const EdgeInsets.only(top: 30),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF140A26),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            textos.infoCodigo,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _construirCampoTexto(
            controlador: _controladorCodigoEscaneado,
            etiqueta: textos.etiquetaIdTarjeta,
            icono: Icons.pin_outlined,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                const Icon(Icons.qr_code_scanner, color: Colors.white70),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(textos.formatoDetectado, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(nombreFormato, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Animación en blanco para simular cómo se vería en caja
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Image.network(
              url, 
              height: 100, 
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.qr_code, color: Colors.black26, size: 80),
            ),
          ),
        ],
      ),
    );
  }

  // Te enseña la foto del ticket por si le sacaste una foto (para que veas que no se ve borrosa)
  Widget _construirPrevisualizacionImagen() {
    if (widget.nuevoArchivoImagen != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Image.file(widget.nuevoArchivoImagen!, height: 200, width: double.infinity, fit: BoxFit.cover),
      );
    } else if (widget.ticketExistente?.urlImagen.isNotEmpty == true) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Image.network(widget.ticketExistente!.urlImagen, height: 200, width: double.infinity, fit: BoxFit.cover),
      );
    }
    return const SizedBox.shrink();
  }

  // Un cajoncito de texto para que todo el formulario se vea igual de moderno
  Widget _construirCampoTexto({
    required TextEditingController controlador,
    required String etiqueta,
    required IconData icono,
    String? pista,
    TextInputType? tipoTeclado,
    Widget? iconoExtra,
    List<TextInputFormatter>? formateadores,
  }) {
    final textos = TextosApp.de(context);
    return TextFormField(
      controller: controlador,
      style: const TextStyle(color: Colors.white),
      keyboardType: tipoTeclado,
      inputFormatters: formateadores,
      decoration: InputDecoration(
        labelText: etiqueta,
        hintText: pista,
        prefixIcon: Icon(icono, color: Colors.white70),
        suffixIcon: iconoExtra,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFFF4081)),
        ),
      ),
      validator: (valor) => valor!.isEmpty ? textos.campoObligatorio : null,
    );
  }

  Widget _construirBotonGuardar() {
    final textos = TextosApp.de(context);
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _cargando ? null : _manejarGuardado, // Si está cargando, lo deshabilitamos para que no le den 80 veces
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
            child: _cargando 
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    textos.botonGuardarTicket,
                    style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }
}
