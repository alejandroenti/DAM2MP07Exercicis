import 'dart:convert';
import 'dart:io';
import 'package:exercici5/widgets/connection_buttons.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dartssh2/dartssh2.dart';
import '../models/server_config.dart';
import '../widgets/custom_input.dart';

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
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Configuració guardada")));
  }

  void _selectServer(ServerConfig server) {
    setState(() {
      selectedServer = server;
      nomCtrl.text = server.nom;
      hostCtrl.text = server.host;
      portCtrl.text = server.port;
      clauCtrl.text = server.clau;
    });
  }

  Future<void> _connectSSH() async {
    if (selectedServer == null) return;

    try {
      // 1. Leer el archivo de la clave privada (id_rsa)
      final keyFile = File(selectedServer!.clau);
      if (!await keyFile.exists()) {
        _showMsg("No s'ha trobat el fitxer id_rsa.");
        return;
      }
      final keyString = await keyFile.readAsString();

      // 2. Configurar el par de claves. Nota: 'identities' suele esperar una lista [keyPair]
      final keyPair = SSHKeyPair.fromPem(keyString);
      
      // 3. Establecer el socket y el cliente
      final socket = await SSHSocket.connect(
        selectedServer!.host, 
        int.parse(selectedServer!.port),
        timeout: const Duration(seconds: 10),
      );

      final client = SSHClient(
        socket,
        username: selectedServer!.nom, // Cambiar según corresponda
        identities: keyPair, 
      );

      // 4. Autenticar. Si falla, lanzará una excepción capturada por el catch.
      await client.authenticated;
      
      _showMsg("Connectat amb èxit a ${selectedServer!.host}", isError: false);
      
      // Aquí puedes navegar a tu pantalla de gestión de archivos pasándole el 'client'

    } catch (e) {
      _showMsg("Error de connexió: $e");
    }
  }

void _showMsg(String text, {bool isError = true}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(text), backgroundColor: isError ? Colors.red : Colors.green)
  );
}

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red)
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.green)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // BARRA LATERAL
          Container(
            width: 280,
            decoration: const BoxDecoration(border: Border(right: BorderSide(color: Colors.black, width: 1.5))),
            child: Column(
              children: [
                _buildSidebarHeader(),
                Expanded(
                  child: ListView.builder(
                    itemCount: servers.length,
                    itemBuilder: (context, i) => ListTile(
                      tileColor: selectedServer == servers[i] ? Colors.grey.shade200 : null,
                      title: Text(servers[i].nom),
                      onTap: () => _selectServer(servers[i]),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // DETALLE (CONDICIONAL)
          Expanded(
            child: selectedServer == null 
              ? const Center(child: Text("Selecciona un servidor per començar", style: TextStyle(color: Colors.grey)))
              : _buildConfigForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Servidors", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.add_box, color: Colors.blue, size: 28),
            onPressed: () {
              setState(() {
                final n = ServerConfig(nom: "Nou Servidor", host: "", port: "22", clau: "");
                servers.add(n);
                _selectServer(n);
              });
            },
          )
        ],
      ),
    );
  }

  Widget _buildConfigForm() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Configuració SSH", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          CustomInput(label: "Nom:", controller: nomCtrl, onChanged: (v) => setState(() => selectedServer!.nom = v)),
          CustomInput(label: "Servidor:", controller: hostCtrl, onChanged: (v) => setState(() => selectedServer!.host = v)),
          CustomInput(label: "Port:", controller: portCtrl, onChanged: (v) => setState(() => selectedServer!.port = v)),
          CustomInput(
            label: "Clau:", 
            controller: clauCtrl, 
            readOnly: true, 
            onTap: () async {
              FilePickerResult? r = await FilePicker.platform.pickFiles();
              if (r != null) setState(() => clauCtrl.text = selectedServer!.clau = r.files.single.path!);
            }
          ),
          const Spacer(),
          _buildFooterButtons(),
        ],
      ),
    );
  }

  Widget _buildFooterButtons() {
  return ConnectionButtons(
    onDelete: () {
      setState(() {
        servers.remove(selectedServer);
        selectedServer = null;
      });
      _saveConfigs();
    },
    onSave: _saveConfigs,
    onConnect: _connectSSH, // <--- Llamada a la lógica SSH
  );
}

  // --- BOTONES CON ESTILO DE LA IMAGEN ---
  Widget _buildIconButton(IconData icon, VoidCallback onTap) => Container(
    decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
    child: IconButton(onPressed: onTap, icon: Icon(icon)),
  );

  Widget _buildTextButton(String text, VoidCallback onTap) => ElevatedButton(
    onPressed: onTap,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white, foregroundColor: Colors.black,
      side: const BorderSide(color: Colors.grey),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18)
    ),
    child: Text(text),
  );

  Widget _buildConnectButton() => Container(
    width: 200,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      gradient: const LinearGradient(colors: [Color(0xFF42A5F5), Color(0xFF1976D2)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
    ),
    child: ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 18)),
      child: const Text("Connectar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    ),
  );
}