import 'dart:math';
import 'package:flutter/material.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class ServerStatsScreen extends StatefulWidget {
  final SSHClient client;
  final String currentPath;
  final List<SftpName> items; // Pasamos los items actuales para el Baobab

  const ServerStatsScreen({
    super.key, 
    required this.client, 
    required this.currentPath, 
    required this.items
  });

  @override
  State<ServerStatsScreen> createState() => _ServerStatsScreenState();
}

class _ServerStatsScreenState extends State<ServerStatsScreen> {
  bool isRedirectActive = false;
  final String targetPort = "3000";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Análisis de Sistema", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Sección Baobab: Visualización de disco interactiva
            Container(
              padding: const EdgeInsets.all(20),
              height: 400,
              child: Column(
                children: [
                  const Text("Distribución de espacio en disco", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Expanded(
                    child: CustomPaint(
                      size: const Size(double.infinity, double.infinity),
                      painter: RealBaobabPainter(items: widget.items),
                    ),
                  ),
                ],
              ),
            ),

            // Widgets de Control Personalizados
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildStatusSection(),
                  const Divider(),
                  _buildPortRedirectWidget(),
                  const SizedBox(height: 20),
                  _buildServiceHierarchy(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget 2 & 5: Estado con Canvas y texto
  Widget _buildStatusSection() {
    return Row(
      children: [
        CustomPaint(
          size: const Size(15, 15),
          painter: StatusCircleCanvas(isActive: true), // Widget Canvas requerido
        ),
        const SizedBox(width: 10),
        const Text("ESTADO: EN FUNCIONAMIENTO", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // Widget 4: Redirección Port 80 -> 3000
  Widget _buildPortRedirectWidget() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Redirección Puerto 80", style: TextStyle(fontWeight: FontWeight.bold)),
              Switch(
                value: isRedirectActive,
                onChanged: (val) => _togglePort80(val),
              ),
            ],
          ),
          Text("Apunta el tráfico HTTP externo hacia el puerto interno $targetPort", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Future<void> _togglePort80(bool active) async {
    setState(() => isRedirectActive = active);
    // Ejecuta la regla de NAT en el servidor
    String cmd = active 
      ? "sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port $targetPort"
      : "sudo iptables -t nat -D PREROUTING -p tcp --dport 80 -j REDIRECT --to-port $targetPort";
    await widget.client.run(cmd);
  }

  // Widget 1: Lista con títulos e identación
  Widget _buildServiceHierarchy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Dependencias del Proyecto", style: TextStyle(fontWeight: FontWeight.bold)),
        _indentItem("NodeJS Engine v18.x", 1),
        _indentItem("Express Framework", 2),
        _indentItem("Body-parser Middleware", 3),
        _indentItem("PM2 Process Manager", 1),
      ],
    );
  }

  Widget _indentItem(String text, int level) {
    return Padding(
      padding: EdgeInsets.only(left: level * 20.0, top: 5),
      child: Text("└─ $text", style: const TextStyle(fontSize: 13, color: Colors.black54)),
    );
  }
}

// --- CANVAS: EL GRÁFICO BAOBAB REAL ---

class RealBaobabPainter extends CustomPainter {
  final List<SftpName> items;
  
  RealBaobabPainter({required this.items});

  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width * 0.35;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 45; // Gruix de l'anell

    // 1. Calculem el pes total per fer els "formatgets" proporcionals
    // Sumem la mida de tots els items (si és null, posem 1024 bytes per defecte)
    double totalSize = items.fold(0, (sum, item) => sum + (item.attr.size ?? 1024));
    double startAngle = -pi / 2; // Comencem a les 12 del rellotge

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final double itemSize = (item.attr.size ?? 1024).toDouble();
      
      // Calculem l'angle segons la proporció de mida
      final sweepAngle = (itemSize / totalSize) * 2 * pi;

      // Assignem colors segons el tipus (Directori vs Fitxer)
      final bool isDir = (item.attr.mode?.value ?? 0) & 0x4000 != 0;
      paint.color = isDir 
          ? Colors.blue.withOpacity(0.7) 
          : Colors.green.withOpacity(0.7);

      // Dibuixem l'arc al Canvas
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }

    // 2. Dibuixem el text central amb la mida total (Descriptiu)
    _drawCenterText(canvas, center, totalSize);
  }

  void _drawCenterText(Canvas canvas, Offset center, double totalSize) {
    final String readableSize = totalSize > 1024 * 1024 
        ? "${(totalSize / (1024 * 1024)).toStringAsFixed(2)} MB"
        : "${(totalSize / 1024).toStringAsFixed(1)} KB";

    final textPainter = TextPainter(
      text: TextSpan(
        text: "TOTAL\n$readableSize",
        style: const TextStyle(
          color: Colors.black, 
          fontWeight: FontWeight.bold, 
          fontSize: 12,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr, // Aquí és on donava l'error
    )..layout();

    textPainter.paint(
      canvas, 
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Painter para el círculo de estado
class StatusCircleCanvas extends CustomPainter {
  final bool isActive;
  StatusCircleCanvas({required this.isActive});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = isActive ? Colors.green : Colors.red..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}