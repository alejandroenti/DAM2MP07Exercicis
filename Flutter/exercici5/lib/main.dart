import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

void main() => runApp(const ProxmoxManagerApp());

class ProxmoxManagerApp extends StatelessWidget {
  const ProxmoxManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proxmox Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}