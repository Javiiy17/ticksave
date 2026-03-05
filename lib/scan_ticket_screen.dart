import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // IMPORTANTE: Librería de escaneo
import 'ticket_detail_screen.dart';

class ScanTicketScreen extends StatefulWidget {
  const ScanTicketScreen({super.key});

  @override
  State<ScanTicketScreen> createState() => _ScanTicketScreenState();
}

class _ScanTicketScreenState extends State<ScanTicketScreen> {
  // Controlador de la cámara
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates, // Evita leer el mismo código muchas veces seguidas
    returnImage: false,
  );

  // 0: Escaneando, 1: Procesando, 2: Éxito
  int _scanState = 0;

  @override
  void dispose() {
    controller.dispose(); // Limpiamos la cámara al salir
    super.dispose();
  }

  // ESTA FUNCIÓN SE EJECUTA CUANDO LA CÁMARA DETECTA UN CÓDIGO REAL
  void _onDetect(BarcodeCapture capture) async {
    // Si ya estamos procesando, ignoramos nuevas detecciones
    if (_scanState != 0) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    // Cogemos el valor del primer código detectado
    final String codeValue = barcodes.first.rawValue ?? "Código desconocido";

    // 1. Detenemos la cámara y mostramos "Procesando"
    setState(() {
      _scanState = 1;
    });

    // Simulamos un pequeño tiempo de carga para que se vea la animación
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // 2. Mostramos "Éxito"
    setState(() {
      _scanState = 2;
    });

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    // 3. Navegamos pasando el valor REAL escaneado
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TicketDetailScreen(
          storeName: "Producto Escaneado", // Aquí podrías buscar en una base de datos según el código
          date: "Hoy",
          price: "Revisar Ticket",
          // Pasamos el código escaneado como si fuera la URL de imagen por ahora para verlo,
          // o usamos una imagen genérica.
          imageUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/aa/Decathlon_Logo.svg/1200px-Decathlon_Logo.svg.png",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Escanear Ticket",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: false,
        elevation: 0,
        actions: [
          // Botón para encender Flash
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => controller.toggleTorch(),
          ),
        ],
      ),
      body: Column(
        children: [
          const Spacer(),

          Center(
            child: SizedBox(
              width: 300,
              height: 400,
              child: Stack(
                children: [
                  // --- 1. CÁMARA REAL ---
                  // Solo mostramos la cámara si estamos en estado 0 (Escaneando)
                  // Si estamos procesando, mostramos fondo negro
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _scanState == 0
                        ? MobileScanner(
                      controller: controller,
                      onDetect: _onDetect, // AQUÍ OCURRE LA MAGIA
                    )
                        : Container(color: Colors.black54),
                  ),

                  // --- 2. CAPAS SUPERIORES (Procesando / Éxito) ---
                  if (_scanState != 0)
                    Center(child: _buildCenterContent()),

                  // --- 3. MARCO AZUL (Overlay) ---
                  CustomPaint(
                    size: const Size(300, 400),
                    painter: ScannerOverlayPainter(),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Texto informativo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _scanState == 0
                  ? "Apunta al código QR o de barras del ticket"
                  : "¡Código detectado! Procesando...",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),

          const SizedBox(height: 30),

          // Espacio inferior para equilibrar
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildCenterContent() {
    if (_scanState == 1) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          CircularProgressIndicator(color: Color(0xFF1877F2), strokeWidth: 4),
          SizedBox(height: 20),
          Text("Leyendo código...", style: TextStyle(color: Colors.white))
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Colors.transparent, shape: BoxShape.circle),
            child: const Icon(Icons.check_circle, color: Colors.green, size: 80),
          ),
          const SizedBox(height: 10),
          const Text("¡Escaneado!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
        ],
      );
    }
  }
}

// --- PINTOR DEL MARCO (Igual que antes) ---
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

    double cornerSize = 30;

    // Esquinas
    canvas.drawLine(const Offset(0, 20), Offset(0, 20 + cornerSize), paintCorner);
    canvas.drawLine(const Offset(20, 0), Offset(20 + cornerSize, 0), paintCorner);
    canvas.drawArc(Rect.fromCircle(center: const Offset(20, 20), radius: 20), 3.14, 1.57, false, paintCorner);

    canvas.drawLine(Offset(size.width, 20), Offset(size.width, 20 + cornerSize), paintCorner);
    canvas.drawLine(Offset(size.width - 20, 0), Offset(size.width - 20 - cornerSize, 0), paintCorner);
    canvas.drawArc(Rect.fromCircle(center: Offset(size.width - 20, 20), radius: 20), -1.57, 1.57, false, paintCorner);

    canvas.drawLine(Offset(0, size.height - 20), Offset(0, size.height - 20 - cornerSize), paintCorner);
    canvas.drawLine(Offset(20, size.height), Offset(20 + cornerSize, size.height), paintCorner);
    canvas.drawArc(Rect.fromCircle(center: Offset(20, size.height - 20), radius: 20), 1.57, 1.57, false, paintCorner);

    canvas.drawLine(Offset(size.width, size.height - 20), Offset(size.width, size.height - 20 - cornerSize), paintCorner);
    canvas.drawLine(Offset(size.width - 20, size.height), Offset(size.width - 20 - cornerSize, size.height), paintCorner);
    canvas.drawArc(Rect.fromCircle(center: Offset(size.width - 20, size.height - 20), radius: 20), 0, 1.57, false, paintCorner);

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(15, 15, size.width - 30, size.height - 30),
      const Radius.circular(10),
    );
    canvas.drawRRect(rrect, paintDashed);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}