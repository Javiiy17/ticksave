import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'ticket_detail_screen.dart';

/// Pantalla encargada de leer códigos del ticket (QR y códigos de barras).
///
/// Usa decodificación de códigos (ML Kit vía `mobile_scanner`), no OCR de texto
/// impreso: es el enfoque adecuado para EAN, UPC, Code 128, QR, etc.
class ScanTicketScreen extends StatefulWidget {
  const ScanTicketScreen({super.key});

  @override
  State<ScanTicketScreen> createState() => _ScanTicketScreenState();
}

class _ScanTicketScreenState extends State<ScanTicketScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
    formats: const [
      BarcodeFormat.qrCode,
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.code93,
      BarcodeFormat.codabar,
      BarcodeFormat.itf,
      BarcodeFormat.dataMatrix,
      BarcodeFormat.pdf417,
      BarcodeFormat.aztec,
    ],
  );

  /// 0: Escaneando, 1: Procesando, 2: Éxito.
  int _scanState = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Se ejecuta cuando la cámara detecta un código válido.
  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_scanState != 0) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final first = barcodes.first;
    final String codeValue =
        (first.displayValue ?? first.rawValue ?? '').trim();
    if (codeValue.isEmpty) return;

    final String formatLabel = _formatLabel(first.format);
    debugPrint('Código leído ($formatLabel): $codeValue');

    setState(() {
      _scanState = 1;
    });

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    setState(() {
      _scanState = 2;
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (context) => TicketDetailScreen(
          storeName: 'Producto escaneado',
          date: 'Hoy',
          price: 'Revisar ticket',
          scannedCode: codeValue,
          barcodeFormatLabel: formatLabel,
          imageUrl:
              'https://upload.wikimedia.org/wikipedia/commons/thumb/a/aa/Decathlon_Logo.svg/1200px-Decathlon_Logo.svg.png',
        ),
      ),
    );
  }

  static String _formatLabel(BarcodeFormat format) {
    return switch (format) {
      BarcodeFormat.ean13 => 'EAN-13',
      BarcodeFormat.ean8 => 'EAN-8',
      BarcodeFormat.upcA => 'UPC-A',
      BarcodeFormat.upcE => 'UPC-E',
      BarcodeFormat.code128 => 'Code 128',
      BarcodeFormat.code39 => 'Code 39',
      BarcodeFormat.code93 => 'Code 93',
      BarcodeFormat.codabar => 'Codabar',
      BarcodeFormat.itf => 'ITF',
      BarcodeFormat.qrCode => 'Código QR',
      BarcodeFormat.dataMatrix => 'Data Matrix',
      BarcodeFormat.pdf417 => 'PDF417',
      BarcodeFormat.aztec => 'Aztec',
      BarcodeFormat.unknown => 'Desconocido',
      BarcodeFormat.all => 'Varios',
    };
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
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Column(
        children: [
          const Spacer(),
          _buildScannerArea(),
          const Spacer(),
          _buildBottomText(),
          const SizedBox(height: 30),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  /// Contenedor central con la vista de cámara y overlays.
  Widget _buildScannerArea() {
    return Center(
      child: SizedBox(
        width: 300,
        height: 400,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: _scanState == 0
                  ? MobileScanner(
                      controller: _controller,
                      onDetect: _onDetect,
                      errorBuilder: (context, error, child) {
                        return ColoredBox(
                          color: Colors.black87,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                error.errorDetails?.message ??
                                    'No se pudo usar la cámara. Revisa permisos y vuelve a intentarlo.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Container(color: Colors.black54),
            ),
            if (_scanState != 0) Center(child: _buildCenterContent()),
            CustomPaint(
              size: const Size(300, 400),
              painter: ScannerOverlayPainter(),
            ),
          ],
        ),
      ),
    );
  }

  /// Texto informativo en la parte inferior.
  Widget _buildBottomText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        _scanState == 0
            ? 'Apunta el código de barras o el QR del ticket'
            : '¡Código detectado! Procesando...',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white70, fontSize: 16),
      ),
    );
  }

  /// Contenido que se muestra encima de la cámara cuando estamos procesando
  /// o cuando el escaneo ha sido exitoso.
  Widget _buildCenterContent() {
    if (_scanState == 1) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          CircularProgressIndicator(
            color: Color(0xFF1877F2),
            strokeWidth: 4,
          ),
          SizedBox(height: 20),
          Text(
            'Leyendo código...',
            style: TextStyle(color: Colors.white),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Padding(
          padding: EdgeInsets.all(16),
          child: Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 80,
          ),
        ),
        SizedBox(height: 10),
        Text(
          '¡Escaneado!',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Dibuja el marco azul y las líneas alrededor del área de escaneo.
class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintCorner = Paint()
      ..color = const Color(0xFF1877F2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final paintDashed = Paint()
      ..color = Colors.white30
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const double cornerSize = 30;

    canvas.drawLine(const Offset(0, 20), const Offset(0, 20 + cornerSize), paintCorner);
    canvas.drawLine(const Offset(20, 0), const Offset(20 + cornerSize, 0), paintCorner);
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(20, 20), radius: 20),
      3.14,
      1.57,
      false,
      paintCorner,
    );

    canvas.drawLine(
      Offset(size.width, 20),
      Offset(size.width, 20 + cornerSize),
      paintCorner,
    );
    canvas.drawLine(
      Offset(size.width - 20, 0),
      Offset(size.width - 20 - cornerSize, 0),
      paintCorner,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width - 20, 20), radius: 20),
      -1.57,
      1.57,
      false,
      paintCorner,
    );

    canvas.drawLine(
      Offset(0, size.height - 20),
      Offset(0, size.height - 20 - cornerSize),
      paintCorner,
    );
    canvas.drawLine(
      Offset(20, size.height),
      Offset(20 + cornerSize, size.height),
      paintCorner,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(20, size.height - 20), radius: 20),
      1.57,
      1.57,
      false,
      paintCorner,
    );

    canvas.drawLine(
      Offset(size.width, size.height - 20),
      Offset(size.width, size.height - 20 - cornerSize),
      paintCorner,
    );
    canvas.drawLine(
      Offset(size.width - 20, size.height),
      Offset(size.width - 20 - cornerSize, size.height),
      paintCorner,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width - 20, size.height - 20), radius: 20),
      0,
      1.57,
      false,
      paintCorner,
    );

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(15, 15, size.width - 30, size.height - 30),
      const Radius.circular(10),
    );
    canvas.drawRRect(rrect, paintDashed);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

