import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const CineApp());

class CineApp extends StatelessWidget {
  const CineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cine DB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainAdaptiveScaffold(),
    );
  }
}

// --- CONFIGURACIÓN DEL SERVIDOR ---
const String baseUrl = "http://localhost:3000"; // Cambia por tu IP si usas móvil físico

class MainAdaptiveScaffold extends StatefulWidget {
  const MainAdaptiveScaffold({super.key});

  @override
  State<MainAdaptiveScaffold> createState() => _MainAdaptiveScaffoldState();
}

class _MainAdaptiveScaffoldState extends State<MainAdaptiveScaffold> {
  Map<String, dynamic>? categories;
  List<dynamic> items = [];
  Map<String, dynamic>? selectedItem;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  // Llamada POST para obtener categorías
  Future<void> _fetchCategories() async {
    final response = await http.post(Uri.parse('$baseUrl/categories'));
    if (response.statusCode == 200) {
      setState(() => categories = json.decode(response.body));
    }
  }

  // Llamada POST para obtener items de una categoría
  Future<void> _fetchItems(String catName) async {
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
  }

  @override
  Widget build(BuildContext context) {
    // Detectamos el ancho de la pantalla para el diseño adaptativo
    double width = MediaQuery.of(context).size.width;
    bool isDesktop = width > 600;

    if (categories == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedItem != null ? selectedItem!['nom'] : "Cine DB"),
        backgroundColor: Colors.blue[200],
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () => _showSearch(context))
        ],
      ),
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
    );
  }

  // --- DISEÑO DESKTOP (Master-Detail) ---
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Columna izquierda: Categorías e Items
        SizedBox(
          width: 300,
          child: Column(
            children: [
              DropdownButton<String>(
                value: selectedCategory,
                hint: const Text("Selecciona Categoria"),
                items: categories!.keys.map((String key) {
                  return DropdownMenuItem(value: key, child: Text(key));
                }).toList(),
                onChanged: (val) => _fetchItems(val!),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) => ListTile(
                    leading: Image.network("$baseUrl${items[index]['imatge']}", width: 40),
                    title: Text(items[index]['nom']),
                    onTap: () => setState(() => selectedItem = items[index]),
                  ),
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(),
        // Columna derecha: Detalle
        Expanded(
          child: selectedItem == null 
            ? const Center(child: Text("Selecciona una pel·lícula"))
            : ItemDetailView(item: selectedItem!),
        )
      ],
    );
  }

  // --- DISEÑO MOBILE (Navegación por pantallas) ---
  Widget _buildMobileLayout() {
    return ListView(
      children: categories!.keys.map((cat) => ListTile(
        title: Text(cat),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () async {
          await _fetchItems(cat);
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => ItemsPage(categoryName: cat, initialItems: items)
          ));
        },
      )).toList(),
    );
  }

  void _showSearch(BuildContext context) {
    showSearch(context: context, delegate: MovieSearchDelegate());
  }
}

// --- VISTA DETALLE (Reutilizable) ---
class ItemDetailView extends StatelessWidget {
  final Map<String, dynamic> item;
  const ItemDetailView({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Image.network("$baseUrl${item['imatge']}", height: 300),
          const SizedBox(height: 20),
          Text(item['nom'], style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          Text("${item['director']} (${item['any']})", style: const TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 20),
          Text(item['sinopsi'], textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            children: (item['plataformes'] as List).map((p) => Chip(label: Text(p))).toList(),
          )
        ],
      ),
    );
  }
}

// --- PÁGINA DE ITEMS (Mobile) ---
class ItemsPage extends StatelessWidget {
  final String categoryName;
  final List<dynamic> initialItems;
  const ItemsPage({super.key, required this.categoryName, required this.initialItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: ListView.builder(
        itemCount: initialItems.length,
        itemBuilder: (context, index) => ListTile(
          leading: Image.network("$baseUrl${initialItems[index]['imatge']}", width: 50),
          title: Text(initialItems[index]['nom']),
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text("Detall")),
              body: ItemDetailView(item: initialItems[index]),
            )
          )),
        ),
      ),
    );
  }
}

// --- BUSCADOR (POST /cerca) ---
class MovieSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) => [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = "")];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder(
      future: http.post(
        Uri.parse('$baseUrl/cerca'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': query}),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final results = json.decode((snapshot.data as http.Response).body)['resultats'] as List;
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(results[index]['nom']),
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (context) => Scaffold(body: ItemDetailView(item: results[index]))
            )),
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) => Container();
}