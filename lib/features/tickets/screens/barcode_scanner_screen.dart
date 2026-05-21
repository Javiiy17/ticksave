import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'edit_ticket_screen.dart';
import '../../../core/l10n/app_strings.dart';

// Diferentes modos en los que puede estar la cámara (código de barras o QR)
enum ModoEscaneo { codigoBarras, qr }

/*
 * ¿Qué hace este archivo?
 * Esta es la pantalla futurista donde se abre la cámara para escanear el código de barras
 * o el QR del ticket. Le hemos metido una animación de una rayita que sube y baja 
 * como los escáneres de verdad de los súper, queda to' guapo. 
 */
class PantallaEscanerCodigo extends StatefulWidget {
  const PantallaEscanerCodigo({super.key});

  @override
  State<PantallaEscanerCodigo> createState() => _EstadoPantallaEscanerCodigo();
}

class _EstadoPantallaEscanerCodigo extends State<PantallaEscanerCodigo> with SingleTickerProviderStateMixin {
  late MobileScannerController _controladorCamara;
  ModoEscaneo _modoActual = ModoEscaneo.codigoBarras;
  bool _esExito = false;
  bool _estaProcesando = false;

  late AnimationController _controladorAnimacion;
  late Animation<double> _animacion;

  @override
  void initState() {
    super.initState();
    // Arrancamos la cámara trasera
    _controladorCamara = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );

    // Configuramos la rayita láser para que suba y baje en 1.5 segundos
    _controladorAnimacion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _animacion = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controladorAnimacion, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    // Hay que limpiar la memoria al salir o peta
    _controladorAnimacion.dispose();
    _controladorCamara.dispose();
    super.dispose();
  }

  // Esta función es clave: salta en cuanto la cámara pilla un código
  Future<void> _procesarCodigo(BarcodeCapture captura) async {
    // Si ya estamos procesando uno o no ha pillado nada, ignoramos
    if (_estaProcesando || captura.barcodes.isEmpty) return;

    final codigoDetectado = captura.barcodes.first;
    if (codigoDetectado.rawValue == null) return;

    setState(() {
      _estaProcesando = true;
      _esExito = true; // Ponemos la pantallita verde de victoria
    });

    _controladorAnimacion.stop(); // Paramos la rayita láser porque ya hemos acertado
    await _controladorCamara.stop(); // Apagamos la cámara para ahorrar batería
    
    // Le dejamos 600 milisegundos al usuario para que vea que se ha puesto verde y mola más
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    String formato = codigoDetectado.format.name;

    // Y pa' la pantalla de edición, pasándole lo que hemos escaneado
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaEditarTicket(
          codigoEscaneado: codigoDetectado.rawValue,
          formatoCodigoBarras: formato,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = TextosApp.de(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(t.tituloEscanearCodigo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // La vista real de la cámara debajo de todo
          MobileScanner(
            controller: _controladorCamara,
            onDetect: _procesarCodigo,
          ),
          // Capa negra semitransparente con un "agujero" en el medio para enfocar
          CustomPaint(
            size: Size.infinite,
            painter: PintorCapaSuperpuesta(modo: _modoActual),
          ),
          // Las esquinitas blancas y la rayita láser animada
          LayoutBuilder(
            builder: (context, constraints) {
              final double anchoPantalla = constraints.maxWidth;
              final double altoPantalla = constraints.maxHeight;

              final esCodigoBarras = _modoActual == ModoEscaneo.codigoBarras;
              // Si es código de barras, el hueco es alargado. Si es QR, es más cuadradote
              final double anchoHueco = esCodigoBarras ? anchoPantalla * 0.85 : anchoPantalla * 0.7;
              final double altoHueco = esCodigoBarras ? altoPantalla * 0.2 : anchoPantalla * 0.7;

              return Center(
                child: SizedBox(
                  width: anchoHueco,
                  height: altoHueco,
                  child: Stack(
                    children: [
                      // Dibujamos las cuatro esquinitas (blancas, o verdes si acertamos)
                      _construirEsquinas(anchoHueco, altoHueco, _esExito ? Colors.greenAccent : Colors.white),
                      // El láser rojo
                      AnimatedBuilder(
                        animation: _animacion,
                        builder: (context, child) {
                          return Positioned(
                            top: _animacion.value * (altoHueco - 4),
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: _esExito ? Colors.greenAccent : Colors.red,
                                boxShadow: [
                                  BoxShadow(
                                    color: (_esExito ? Colors.greenAccent : Colors.red).withValues(alpha: 0.6),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  )
                                ],
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Botonera de abajo para cambiar entre código de barras o QR
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _construirBotonModo(
                  titulo: t.pestanaBarras,
                  icono: Icons.view_headline,
                  modo: ModoEscaneo.codigoBarras,
                ),
                const SizedBox(width: 20),
                _construirBotonModo(
                  titulo: t.pestanaQr,
                  icono: Icons.qr_code_2,
                  modo: ModoEscaneo.qr,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Los botones con formita de píldora
  Widget _construirBotonModo({required String titulo, required IconData icono, required ModoEscaneo modo}) {
    final bool estaSeleccionado = _modoActual == modo;
    return GestureDetector(
      onTap: () {
        if (_estaProcesando) return;
        setState(() {
          _modoActual = modo;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: estaSeleccionado ? const Color(0xFFE91E63) : Colors.black54,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: estaSeleccionado ? const Color(0xFFE91E63) : Colors.white24,
          ),
        ),
        child: Row(
          children: [
            Icon(icono, color: estaSeleccionado ? Colors.white : Colors.white54, size: 20),
            const SizedBox(width: 8),
            Text(
              titulo,
              style: TextStyle(
                color: estaSeleccionado ? Colors.white : Colors.white54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Pinta las 4 esquinitas del borde del escáner
  Widget _construirEsquinas(double ancho, double alto, Color color) {
    const double longitud = 30.0;
    const double grosor = 5.0;

    return Stack(
      children: [
        Positioned(
          top: 0, left: 0,
          child: _elementoEsquina(longitud, grosor, color, esArriba: true, esIzquierda: true),
        ),
        Positioned(
          top: 0, right: 0,
          child: _elementoEsquina(longitud, grosor, color, esArriba: true, esIzquierda: false),
        ),
        Positioned(
          bottom: 0, left: 0,
          child: _elementoEsquina(longitud, grosor, color, esArriba: false, esIzquierda: true),
        ),
        Positioned(
          bottom: 0, right: 0,
          child: _elementoEsquina(longitud, grosor, color, esArriba: false, esIzquierda: false),
        ),
      ],
    );
  }

  // Función matemática para pintar cada esquinita suelta
  Widget _elementoEsquina(double longitud, double grosor, Color color, {required bool esArriba, required bool esIzquierda}) {
    return Container(
      width: longitud,
      height: longitud,
      decoration: BoxDecoration(
        border: Border(
          top: esArriba ? BorderSide(color: color, width: grosor) : BorderSide.none,
          bottom: !esArriba ? BorderSide(color: color, width: grosor) : BorderSide.none,
          left: esIzquierda ? BorderSide(color: color, width: grosor) : BorderSide.none,
          right: !esIzquierda ? BorderSide(color: color, width: grosor) : BorderSide.none,
        ),
      ),
    );
  }
}

/*
 * Esto es código de bajo nivel de Flutter para pintar cosas raras en la pantalla.
 * Lo usamos para hacer que la pantalla se vea negra medio transparente y dejar un hueco
 * limpio en medio donde el usuario tiene que enfocar el código.
 */
class PintorCapaSuperpuesta extends CustomPainter {
  final ModoEscaneo modo;

  PintorCapaSuperpuesta({required this.modo});

  @override
  void paint(Canvas canvas, Size tamano) {
    final double ancho = tamano.width;
    final double alto = tamano.height;

    final esCodigoBarras = modo == ModoEscaneo.codigoBarras;
    final double anchoHueco = esCodigoBarras ? ancho * 0.85 : ancho * 0.7;
    final double altoHueco = esCodigoBarras ? alto * 0.2 : ancho * 0.7;

    final double izquierda = (ancho - anchoHueco) / 2;
    final double arriba = (alto - altoHueco) / 2;

    // El huequito de en medio con sus bordes redondos
    final RRect rectanguloRecorte = RRect.fromRectAndRadius(
      Rect.fromLTWH(izquierda, arriba, anchoHueco, altoHueco),
      const Radius.circular(20),
    );

    // Pintamos toda la pantalla de negro al 70% menos el hueco
    final Paint pinturaFondo = Paint()..color = Colors.black.withValues(alpha: 0.7);
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, ancho, alto)),
        Path()..addRRect(rectanguloRecorte),
      ),
      pinturaFondo,
    );
  }

  @override
  bool shouldRepaint(covariant PintorCapaSuperpuesta oldDelegate) {
    // Solo repintamos si cambiamos de código de barras a QR o al revés
    return oldDelegate.modo != modo;
  }
}
