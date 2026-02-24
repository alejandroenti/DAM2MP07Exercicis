import 'dart:math';
import 'package:flutter/material.dart';
import 'package:dartssh2/dartssh2.dart';
import 'dart:ui' as ui;

class ServerStatsScreen extends StatefulWidget {
  final SSHClient client;
  final String currentPath;
  final List<SftpName> items;

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
  // Estats per als ginys
  bool isServerActive = true; 
  bool isRedirectEnabled = false;
  String serverStatus = "En funcionament"; // funcionament, aturat, reiniciant, error
  Offset? _hoverPosition;
  final TextEditingController _configController = TextEditingController(text: "srv-proxmox-01");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Anàlisi: ${widget.currentPath}"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView( // Permet l'scroll si no caben els ginys
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- GRÀFIC BAOBAB INTERACTIU ---
            const Text("Distribució de fitxers", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Center(
              child: GestureDetector(
                onPanUpdate: (d) => setState(() => _hoverPosition = d.localPosition),
                onPanEnd: (_) => setState(() => _hoverPosition = null),
                child: SizedBox(
                  width: 250,
                  height: 250,
                  child: CustomPaint(
                    painter: RealBaobabPainter(items: widget.items, hoverPosition: _hoverPosition),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // 1. Widget: Llista amb títols en negreta i items identats
            const CustomIndentList(
              title: "Dependències del Projecte",
              subItems: ["NodeJS v18", "Express.js", "DartSSH2", "Flutter SDK"],
            ),
            const Divider(),

            // 2. Widget: Cercle d'estat (Canvas) + 5. Estat del servidor
            _buildStatusHeader(),
            const Divider(),

            // 3. Widget: Camp de text amb títol i part editable
            _buildEditableConfig(),
            const Divider(),

            // 4. Widget: Configuració Redirecció Port 80
            _buildPortRedirector(),
            
            const SizedBox(height: 40), // Espai final per l'scroll
          ],
        ),
      ),
    );
  }

  // Giny 2 i 5: Cercle Canvas i Text d'estat
  Widget _buildStatusHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CustomPaint(
            size: const Size(20, 20),
            painter: StatusCircleCanvas(isActive: isServerActive),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("ESTAT DEL SERVIDOR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text(serverStatus.toUpperCase(), 
                style: TextStyle(color: isServerActive ? Colors.green : Colors.red, fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }

  // Giny 3: Editable amb títol
  Widget _buildEditableConfig() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Hostname del Servidor", style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(
            controller: _configController,
            decoration: const InputDecoration(hintText: "Escriu el nom..."),
          ),
        ],
      ),
    );
  }

  // Giny 4: Redirecció Port 80
  Widget _buildPortRedirector() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text("Redirecció Port 80 → 3000", style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: const Text("Activa el trànsit web estàndard cap a NodeJS"),
      trailing: Switch(
        value: isRedirectEnabled,
        onChanged: (val) {
          setState(() => isRedirectEnabled = val);
          // Aquí aniria la lògica 'sudo iptables' que teníem abans
        },
      ),
    );
  }
}

// --- IMPLEMENTACIÓ DELS PAINTERS I WIDGETS AUXILIARS ---

// 1. Widget: Llista identada
class CustomIndentList extends StatelessWidget {
  final String title;
  final List<String> subItems;
  const CustomIndentList({super.key, required this.title, required this.subItems});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ...subItems.map((item) => Padding(
          padding: const EdgeInsets.only(left: 24, bottom: 6),
          child: InkWell(
            onTap: () {}, // Seleccionable
            child: Text("• $item", style: const TextStyle(fontSize: 14, color: Colors.black87)),
          ),
        )),
      ],
    );
  }
}

// 2. Widget: Cercle d'estat amb Canvas
class StatusCircleCanvas extends CustomPainter {
  final bool isActive;
  StatusCircleCanvas({required this.isActive});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isActive ? Colors.green : Colors.red
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Painter del Baobab Interactiu (versió corregida amb hoverPosition)
class RealBaobabPainter extends CustomPainter {
  final List<SftpName> items;
  final Offset? hoverPosition;
  RealBaobabPainter({required this.items, this.hoverPosition});

  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty) return;
    final center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width * 0.35;
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 35;

    double totalSize = items.fold(0, (sum, item) => sum + (item.attr.size ?? 1024));
    double startAngle = -pi / 2;
    String? hoveredName;

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      double sweepAngle = ((item.attr.size ?? 1024) / totalSize) * 2 * pi;
      if (sweepAngle < 0.1) sweepAngle = 0.1;

      bool isHovered = false;
      if (hoverPosition != null) {
        final dist = (hoverPosition! - center).distance;
        if (dist > radius - 20 && dist < radius + 20) {
          double angle = atan2(hoverPosition!.dy - center.dy, hoverPosition!.dx - center.dx);
          if (angle < -pi / 2) angle += 2 * pi;
          if (angle >= startAngle && angle <= startAngle + sweepAngle) {
            isHovered = true;
            hoveredName = item.filename;
          }
        }
      }

      paint.color = Colors.primaries[i % Colors.primaries.length].withOpacity(isHovered ? 1.0 : 0.5);
      paint.strokeWidth = isHovered ? 45 : 35;

      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle + 0.02, sweepAngle - 0.02, false, paint);
      startAngle += sweepAngle;
    }
    _drawCenterText(canvas, center, hoveredName ?? "${(totalSize / 1024).toStringAsFixed(0)} KB");
  }

  void _drawCenterText(Canvas canvas, Offset center, String text) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    )..layout(maxWidth: 80);
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant RealBaobabPainter oldDelegate) => oldDelegate.hoverPosition != hoverPosition;
}