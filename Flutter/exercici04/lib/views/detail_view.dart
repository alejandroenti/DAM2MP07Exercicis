import 'package:flutter/material.dart';
import '../main.dart';

class ItemDetailView extends StatelessWidget {
  final Map<String, dynamic> item;
  const ItemDetailView({super.key, required this.item});

  Color _getPlatformColor(String name) {
    switch (name.toLowerCase()) {
      case 'netflix': return Colors.redAccent;
      case 'hbo': return Colors.deepPurple;
      case 'disney+': return Colors.blue.shade900;
      case 'amazon': return Colors.orange;
      default: return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final plataformas = item['plataformes'] as List? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network("$baseUrl${item['imatge']}", height: 350),
          ),
          const SizedBox(height: 20),
          Text(item['nom'], style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          Text("${item['director']} (${item['any']})", style: const TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 15),
          
          Wrap(
            spacing: 8,
            children: plataformas.map((p) => Chip(
              label: Text(p, style: const TextStyle(color: Colors.white, fontSize: 12)),
              backgroundColor: _getPlatformColor(p),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            )).toList(),
          ),
          
          const SizedBox(height: 20),
          Text(item['sinopsi'], textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}