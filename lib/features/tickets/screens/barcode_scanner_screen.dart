import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'edit_ticket_screen.dart';

/// Define los modos de escaneo soportados por la pantalla.
/// @author Javier Abellán
enum ScanMode { barcode, qr }

/// Pantalla encargada de inicializar la cámara y analizar en tiempo real
/// los códigos de barras y códigos QR utilizando la librería mobile_scanner.
/// @author Javier Abellán
class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> with SingleTickerProviderStateMixin {
  late MobileScannerController controller;
  ScanMode _currentMode = ScanMode.barcode;
  bool _isSuccess = false;
  bool _isProcessing = false;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    controller.dispose();
    super.dispose();
  }

  /// Procesa el resultado de captura del escáner en tiempo real.
  /// Cuando detecta un código válido, detiene la animación y navega a la pantalla de edición.
  /// 
  /// [capture] Contiene la lista de códigos detectados por la cámara.
  /// @author Javier Abellán
  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing || capture.barcodes.isEmpty) return;

    final barcode = capture.barcodes.first;
    if (barcode.rawValue == null) return;

    setState(() {
      _isProcessing = true;
      _isSuccess = true;
    });

    _animationController.stop(); // Parar la animación al acertar
    await controller.stop(); // Detener escáner con v5
    
    // Dejar un tiempo para que el usuario vea la pantalla en verde
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    String formatLabel = barcode.format.name;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EditTicketScreen(
          scannedCode: barcode.rawValue,
          barcodeFormatLabel: formatLabel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Escanear Código', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _handleBarcode,
          ),
          // Capa semi-transparente oscurecida con el recorte
          CustomPaint(
            size: Size.infinite,
            painter: OverlayPainter(mode: _currentMode),
          ),
          // Línea animada y bordes
          LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;
              final double height = constraints.maxHeight;

              final isBarcode = _currentMode == ScanMode.barcode;
              final double rectWidth = isBarcode ? width * 0.85 : width * 0.7;
              final double rectHeight = isBarcode ? height * 0.2 : width * 0.7;

              return Center(
                child: SizedBox(
                  width: rectWidth,
                  height: rectHeight,
                  child: Stack(
                    children: [
                      // Cuatro esquinas decorativas
                      _buildCorners(rectWidth, rectHeight, _isSuccess ? Colors.greenAccent : Colors.white),
                      // Línea escáner que sube y baja
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Positioned(
                            top: _animation.value * (rectHeight - 4),
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: _isSuccess ? Colors.greenAccent : Colors.red,
                                boxShadow: [
                                  BoxShadow(
                                    color: (_isSuccess ? Colors.greenAccent : Colors.red).withValues(alpha: 0.6),
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
          // Botones inferiores para alternar
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildModeButton(
                  title: 'Barras',
                  icon: Icons.view_headline,
                  mode: ScanMode.barcode,
                ),
                const SizedBox(width: 20),
                _buildModeButton(
                  title: 'Código QR',
                  icon: Icons.qr_code_2,
                  mode: ScanMode.qr,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({required String title, required IconData icon, required ScanMode mode}) {
    final bool isSelected = _currentMode == mode;
    return GestureDetector(
      onTap: () {
        if (_isProcessing) return;
        setState(() {
          _currentMode = mode;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE91E63) : Colors.black54,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? const Color(0xFFE91E63) : Colors.white24,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.white54, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorners(double width, double height, Color color) {
    const double length = 30.0;
    const double strokeWidth = 5.0;

    return Stack(
      children: [
        // Top Left
        Positioned(
          top: 0, left: 0,
          child: _cornerElement(length, strokeWidth, color, top: true, left: true),
        ),
        // Top Right
        Positioned(
          top: 0, right: 0,
          child: _cornerElement(length, strokeWidth, color, top: true, left: false),
        ),
        // Bottom Left
        Positioned(
          bottom: 0, left: 0,
          child: _cornerElement(length, strokeWidth, color, top: false, left: true),
        ),
        // Bottom Right
        Positioned(
          bottom: 0, right: 0,
          child: _cornerElement(length, strokeWidth, color, top: false, left: false),
        ),
      ],
    );
  }

  Widget _cornerElement(double length, double thickness, Color color, {required bool top, required bool left}) {
    return Container(
      width: length,
      height: length,
      decoration: BoxDecoration(
        border: Border(
          top: top ? BorderSide(color: color, width: thickness) : BorderSide.none,
          bottom: !top ? BorderSide(color: color, width: thickness) : BorderSide.none,
          left: left ? BorderSide(color: color, width: thickness) : BorderSide.none,
          right: !left ? BorderSide(color: color, width: thickness) : BorderSide.none,
        ),
      ),
    );
  }
}

/// Pintor personalizado para dibujar la capa semitransparente oscura
/// junto con la zona de recorte (agujero transparente) según el modo de escaneo.
/// @author Javier Abellán
class OverlayPainter extends CustomPainter {
  final ScanMode mode;

  OverlayPainter({required this.mode});

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    final isBarcode = mode == ScanMode.barcode;
    final double rectWidth = isBarcode ? width * 0.85 : width * 0.7;
    // SafeArea hace más pequeña la vista, pero para el overlay usamos proporciones parecidas
    final double rectHeight = isBarcode ? height * 0.2 : width * 0.7;

    final double left = (width - rectWidth) / 2;
    // Lo subimos ligeramente al centro
    final double top = (height - rectHeight) / 2;

    final RRect scanRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, rectWidth, rectHeight),
      const Radius.circular(20),
    );

    // Dibuja el fondo negro opaco
    final Paint bgPaint = Paint()..color = Colors.black.withValues(alpha: 0.7);
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, width, height)),
        Path()..addRRect(scanRect),
      ),
      bgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant OverlayPainter oldDelegate) {
    return oldDelegate.mode != mode;
  }
}
