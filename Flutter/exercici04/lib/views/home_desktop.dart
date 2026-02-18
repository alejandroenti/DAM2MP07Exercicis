import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../main.dart'; // Importante para acceder a baseUrl
import 'detail_view.dart';
import 'search_delegate.dart';

class HomeDesktop extends StatefulWidget {
  const HomeDesktop({super.key});

  @override
  State<HomeDesktop> createState() => _HomeDesktopState();
}

class _HomeDesktopState extends State<HomeDesktop> {
  Map<String, dynamic>? categories;
  List<dynamic> items = [];
  Map<String, dynamic>? selectedItem;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/categories'));
      if (response.statusCode == 200) {
        setState(() => categories = json.decode(response.body));
      }
    } catch (e) {
      debugPrint("Error cargando categorías: $e");
    }
  }

  Future<void> _fetchItems(String catName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/categoria/items'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'categoria': catName}),
      );
      if (response.statusCode == 200) {
        setState(() {
          items = json.decode(response.body)['items'];
          selectedCategory = catName;
        });
      }
    } catch (e) {
      debugPrint("Error cargando items: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (categories == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cine DB Desktop"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final result = await showSearch(
                context: context, 
                delegate: MovieSearchDelegate()
              );
              if (result != null) {
                setState(() => selectedItem = result);
              }
            },
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: Row(
        children: [
          Container(
            width: 350,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(right: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Filtrar por Categoría",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    value: selectedCategory,
                    items: categories!.keys.map((k) => DropdownMenuItem(
                      value: k, 
                      child: Text(k)
                    )).toList(),
                    onChanged: (val) => _fetchItems(val!),
                  ),
                ),
                Expanded(
                  child: items.isEmpty 
                    ? const Center(child: Text("Selecciona una categoría"))
                    : ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final isSelected = selectedItem == item;

                          return ListTile(
                            selected: isSelected,
                            selectedTileColor: Colors.blue.withOpacity(0.1),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                "$baseUrl${item['imatge']}",
                                width: 40,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.movie),
                              ),
                            ),
                            title: Text(
                              item['nom'],
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(item['director']),
                            onTap: () {
                              setState(() => selectedItem = item);
                            },
                          );
                        },
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: selectedItem == null
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.movie_filter, size: 100, color: Colors.grey),
                          SizedBox(height: 16),
                          Text("Selecciona una película para ver los detalles",
                              style: TextStyle(fontSize: 18, color: Colors.grey)),
                        ],
                      ),
                    )
                  : ItemDetailView(item: selectedItem!),
            ),
          ),
        ],
      ),
    );
  }
}