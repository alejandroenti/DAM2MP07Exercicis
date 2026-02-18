import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(const ProxmoxManagerApp());

class ProxmoxManagerApp extends StatelessWidget {
  const ProxmoxManagerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const MainScreen(),
    );
  }
}

// --- MODELOS ---
class ServerConfig {
  String nom;
  String host;
  int port;
  String clau;

  ServerConfig({required this.nom, required this.host, required this.port, required this.clau});

  Map<String, dynamic> toJson() => {'nom': nom, 'host': host, 'port': port, 'clau': clau};
  factory ServerConfig.fromJson(Map<String, dynamic> json) => 
    ServerConfig(nom: json['nom'], host: json['host'], port: json['port'], clau: json['clau']);
}

// --- WIDGETS PERSONALIZADOS REQUERIDOS ---

/// 1. Widget de estat con Canvas (Círculo verde/rojo)
class StatusCanvas extends StatelessWidget {
  final bool active;
  const StatusCanvas({super.key, required this.active});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(12, 12),
      painter: _CirclePainter(active ? Colors.green : Colors.red),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final Color color;
  _CirclePainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(size.width/2, size.height/2), size.width/2, Paint()..color = color);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 2. Widget de camp de text personalizado
class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  const CustomTextField({super.key, required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text("**$label:**", style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: TextField(controller: controller, decoration: const InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.zero), contentPadding: EdgeInsets.symmetric(horizontal: 8)))),
        ],
      ),
    );
  }
}

/// 3. Widget Árbol Baobab con Canvas
class BaobabDiskChart extends CustomPainter {
  final List<double> segments = [40, 30, 20, 10]; // Ejemplo de % de uso
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: size.width / 3);
    double startAngle = -1.57; // Empieza arriba

    final colors = [Colors.green, Colors.blue, Colors.purple, Colors.red, Colors.orange];
    
    for (var i = 0; i < segments.length; i++) {
      final sweepAngle = (segments[i] / 100) * 6.28;
      canvas.drawArc(rect, startAngle, sweepAngle, false, 
        Paint()..color = colors[i % colors.length]..style = PaintingStyle.stroke..strokeWidth = 20);
      startAngle += sweepAngle;
    }
    // Dibujar el centro con el texto de capacidad
    TextPainter(text: const TextSpan(text: "617.6 MB", style: TextStyle(color: Colors.black, fontSize: 10)), textDirection: TextDirection.ltr)
      ..layout()..paint(canvas, center - const Offset(20, 5));
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// --- PANTALLA PRINCIPAL ---
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<ServerConfig> servers = [];
  ServerConfig? selectedServer;
  final nomCtrl = TextEditingController();
  final hostCtrl = TextEditingController();
  final portCtrl = TextEditingController();
  final clauCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadConfigs();
  }

  // Carga configuraciones desde JSON local
  Future<void> _loadConfigs() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/configuracio.json');
    if (await file.exists()) {
      final List<dynamic> jsonList = jsonDecode(await file.readAsString());
      setState(() {
        servers = jsonList.map((e) => ServerConfig.fromJson(e)).toList();
      });
    }
  }

  Future<void> _saveConfigs() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/configuracio.json');
    await file.writeAsString(jsonEncode(servers.map((e) => e.toJson()).toList()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Llista de servidors (Izquierda)
          Container(
            width: 250,
            decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.grey.shade300))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(padding: EdgeInsets.all(16.0), child: Text("Servidors", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                Expanded(
                  child: ListView.builder(
                    itemCount: servers.length,
                    itemBuilder: (context, index) {
                      final s = servers[index];
                      return ListTile(
                        title: Text("Proxmox ${s.nom}", style: const TextStyle(fontSize: 14)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: Text(s.nom, style: const TextStyle(fontSize: 12)),
                        ),
                        selected: selectedServer == s,
                        onTap: () => setState(() => selectedServer = s),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Detall y Configuració (Derecha)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Configuració SSH", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  CustomTextField(label: "Nom", controller: nomCtrl),
                  CustomTextField(label: "Servidor", controller: hostCtrl),
                  CustomTextField(label: "Port", controller: portCtrl),
                  CustomTextField(label: "Clau", controller: clauCtrl),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(onPressed: () {}, icon: const Icon(Icons.delete_outline)),
                      ElevatedButton(onPressed: () {}, child: const Text("Afegir a favorits")),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                        onPressed: () {
                          // Navegar a la gestión de archivos
                          Navigator.push(context, MaterialPageRoute(builder: (context) => FileBrowserScreen(config: selectedServer!)));
                        }, 
                        child: const Text("Connectar")
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

// --- PANTALLA GESTIÓN DE ARCHIVOS ---
class FileBrowserScreen extends StatelessWidget {
  final ServerConfig config;
  const FileBrowserScreen({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Proxmox Drive")),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // Menú lateral
                Container(
                  width: 200,
                  child: ListView(
                    children: const [
                      ListTile(title: Text("Recents")),
                      ListTile(title: Text("Carpetes"), selected: true),
                      ListTile(title: Text("Eliminats")),
                    ],
                  ),
                ),
                // Llista d'arxius
                Expanded(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.folder),
                        title: const Text("carpeta A1"),
                        trailing: const Icon(Icons.info_outline),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: const Icon(Icons.description),
                        title: const Text("dades.zip"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [Icon(Icons.download), Icon(Icons.info_outline), Icon(Icons.open_in_full), Icon(Icons.delete)],
                        ),
                      ),
                      // Visualizador Baobab al final
                      const Divider(),
                      const Text("Uso de Disco (Baobab Style)"),
                      SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: CustomPaint(painter: BaobabDiskChart()),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          // Footer de estado del servidor (NodeJS/Java)
          Container(
            color: Colors.blue.shade100,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const StatusCanvas(active: true),
                const SizedBox(width: 10),
                const Text("Servidor NodeJS funcionant al port 3000"),
                const Spacer(),
                const Icon(Icons.settings),
              ],
            ),
          )
        ],
      ),
    );
  }
}