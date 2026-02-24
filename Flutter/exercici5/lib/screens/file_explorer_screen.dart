import 'dart:typed_data';
import 'dart:io';
import 'package:dartssh2/dartssh2.dart';
import 'package:exercici5/models/server_config.dart';
import 'package:exercici5/screens/server_stats_screen.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive_io.dart';

class FileExplorerScreen extends StatefulWidget {
  final SSHClient client;
  final ServerConfig config;
  const FileExplorerScreen({super.key, required this.client, required this.config});

  @override
  State<FileExplorerScreen> createState() => _FileExplorerScreenState();
}

class _FileExplorerScreenState extends State<FileExplorerScreen> {
  late SftpClient sftp;
  List<SftpName> items = [];
  List<String> directoryStack = [];
  String currentPath = '.'; 
  bool isLoading = true, isServerRunning = false, isServerFolder = false;
  String? serverType;
  int serverPort = 3000;

  @override
  void initState() { super.initState(); _init(); }

  Future<void> _init() async { sftp = await widget.client.sftp(); _load(); }

  Future<void> _load() async {
    setState(() => isLoading = true);
    final list = await sftp.listdir(currentPath);
    items = list.where((i) => i.filename != '.' && i.filename != '..').toList();
    
    // Detección de servidor NodeJS/Java
    serverType = items.any((i) => i.filename == 'package.json') ? 'NodeJS' : 
                 items.any((i) => i.filename == 'pom.xml' || i.filename.endsWith('.jar')) ? 'Java' : null;
    isServerFolder = serverType != null;
    if (isServerFolder) {
      final res = await widget.client.run('lsof -i :$serverPort');
      isServerRunning = res.isNotEmpty;
    }
    setState(() => isLoading = false);
  }

  // --- GESTIÓN SERVIDOR ---
  Future<void> _cmdServer(String action) async {
    setState(() => isLoading = true);
    try {
      if (action == 'STOP' || action == 'RESTART') {
        // Executa la comanda definida al teu package.json
        await widget.client.run('cd "$currentPath" && node --run pm2stop');
      }

      if (action == 'START' || action == 'RESTART') {
        // Arrenca usant PM2 tal com està al teu script
        await widget.client.run('cd "$currentPath" && node --run pm2start');
        
        // Mantenim la redirecció de ports perquè puguis accedir-hi
        await widget.client.forwardLocal('127.0.0.1', serverPort);
      }
      
      await Future.delayed(const Duration(seconds: 2));
      _load(); 
    } catch (e) {
      _showMsg("Error PM2: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // --- FICHEROS Y COMPRESIÓN ---
  Future<void> _upload() async {
    String? path = await FilePicker.platform.getDirectoryPath() ?? (await FilePicker.platform.pickFiles())?.files.single.path;
    if (path == null) return;
    setState(() => isLoading = true);
    String name = path.split(Platform.pathSeparator).last;
    bool isDir = FileSystemEntity.isDirectorySync(path);

    if (isDir) {
      final zipP = '${(await getTemporaryDirectory()).path}/$name.zip';
      ZipFileEncoder().zipDirectory(Directory(path), filename: zipP);
      path = zipP; name += ".zip";
    }

    final f = await sftp.open("$currentPath/$name", mode: SftpFileOpenMode.create | SftpFileOpenMode.write);
    await f.write(File(path).openRead().cast<Uint8List>());
    await f.close();

    if (isDir) {
      await widget.client.run('unzip -o "$currentPath/$name" -d "$currentPath/" && rm "$currentPath/$name"');
    }
    _load();
  }

  Future<void> _download(SftpName item, bool isDir) async {
    Directory? d = Platform.isAndroid ? Directory('/storage/emulated/0/Download') : await getDownloadsDirectory();
    String name = isDir ? "${item.filename}.zip" : item.filename;
    if (isDir) await widget.client.run('cd "$currentPath" && zip -r "$name" "${item.filename}"');
    
    final rf = await sftp.open("$currentPath/$name");
    await File("${d!.path}/$name").openWrite().addStream(rf.read());
    await rf.close();
    if (isDir) await sftp.remove("$currentPath/$name");
    _showMsg("Baixat a Downloads");
  }

  // --- UI COMPONENTS ---
  void _showFileInfo(SftpName item) {
    final rawTime = item.attr.modifyTime;
    DateTime date;

    // Corregim l'error assignant el tipus correctament mitjançant comprovació
    if (rawTime is DateTime) {
      date = rawTime as DateTime;
    } else if (rawTime is int) {
      date = DateTime.fromMillisecondsSinceEpoch(rawTime * 1000);
    } else {
      date = DateTime.now(); // Valor per defecte si és null o desconegut
    }

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(item.filename),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Modificat: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(date.toLocal())}"),
            Text("Permisos: ${(item.attr.mode?.value ?? 0 & 0xFFF).toRadixString(8)}"),
            Text("Mida: ${((item.attr.size ?? 0) / 1024).toStringAsFixed(2)} KB"),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text("Tancar"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: directoryStack.isEmpty ? null : IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () {
          setState(() => currentPath = directoryStack.removeLast()); _load();
        }),
        title: Text(currentPath == '.' ? "Inici" : currentPath.split('/').last, style: const TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServerStatsScreen(
                    client: widget.client,
                    currentPath: currentPath,
                    items: items, // Ara sí, passem la llista real de fitxers
                  ),
                ),
              );
            },
          ),
          IconButton(icon: const Icon(Icons.refresh, color: Colors.black), onPressed: _load)],
      ),
      body: isLoading ? const Center(child: CircularProgressIndicator()) : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              _btn("Pujar", _upload), const SizedBox(width: 10),
              _btn("Afegir nou", () => _showCreateDialog()),
            ]),
          ),
          Expanded(child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (c, i) {
              final item = items[i];
              bool isDir = (item.attr.mode?.value ?? 0) & 0x4000 != 0;
              return ListTile(
                leading: Icon(isDir ? Icons.folder : Icons.insert_drive_file, color: Colors.grey),
                title: Text(item.filename),
                trailing: _rowActions(item, isDir),
                onTap: isDir ? () { directoryStack.add(currentPath); currentPath += "/${item.filename}"; _load(); } : null,
              );
            },
          )),
          if (isServerFolder) _serverBar(),
        ],
      ),
    );
  }

  Widget _rowActions(SftpName item, bool isDir) => Row(mainAxisSize: MainAxisSize.min, children: [
    IconButton(icon: const Icon(Icons.download, size: 20), onPressed: () => _download(item, isDir)),
    IconButton(icon: const Icon(Icons.info_outline, size: 20), onPressed: () => _showFileInfo(item)),
    IconButton(icon: const Icon(Icons.delete, size: 20), onPressed: () async { await (isDir ? sftp.rmdir("$currentPath/${item.filename}") : sftp.remove("$currentPath/${item.filename}")); _load(); }),
  ]);

  Widget _serverBar() => Container(
    padding: const EdgeInsets.all(12), color: Colors.blue.shade50,
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(children: [Icon(Icons.circle, color: isServerRunning ? Colors.green : Colors.red, size: 12), const SizedBox(width: 8), Text("Servidor $serverType port $serverPort")]),
      Row(children: [
        IconButton(icon: Icon(isServerRunning ? Icons.refresh : Icons.play_arrow), onPressed: () => _cmdServer(isServerRunning ? 'RESTART' : 'START')),
        if (isServerRunning) IconButton(icon: const Icon(Icons.stop, color: Colors.red), onPressed: () => _cmdServer('STOP')),
      ])
    ]),
  );

  Widget _btn(String t, VoidCallback f) => ElevatedButton(onPressed: f, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, side: const BorderSide(color: Colors.grey)), child: Text(t));

  void _showMsg(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _showCreateDialog() async {
    String type = 'Fitxer'; final ctrl = TextEditingController();
    showDialog(context: context, builder: (c) => StatefulBuilder(builder: (c, setS) => AlertDialog(
      title: const Text("Nou"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButton<String>(value: type, items: ['Fitxer', 'Directori'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setS(() => type = v!)),
        TextField(controller: ctrl),
      ]),
      actions: [TextButton(onPressed: () async {
        if (type == 'Directori') await sftp.mkdir("$currentPath/${ctrl.text}");
        else await (await sftp.open("$currentPath/${ctrl.text}", mode: SftpFileOpenMode.create)).close();
        Navigator.pop(c); _load();
      }, child: const Text("Crear"))],
    )));
  }
}