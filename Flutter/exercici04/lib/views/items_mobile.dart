import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../main.dart';
import 'detail_view.dart';

class ItemsMobile extends StatelessWidget {
  final String categoryName;
  const ItemsMobile({super.key, required this.categoryName});

  Future<List> _fetchItems() async {
    final response = await http.post(
      Uri.parse('$baseUrl/categoria/items'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'categoria': categoryName}),
    );
    return json.decode(response.body)['items'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("CineDB - $categoryName")),
      body: FutureBuilder<List>(
        future: _fetchItems(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final items = snapshot.data!;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    "$baseUrl${item['imatge']}", 
                    width: 50, height: 70, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.movie),
                  ),
                ),
                title: Text(item['nom']),
                subtitle: Text(item['director']),
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(title: const Text("Detalle")),
                    body: ItemDetailView(item: item),
                  )
                )),
              );
            },
          );
        },
      ),
    );
  }
}