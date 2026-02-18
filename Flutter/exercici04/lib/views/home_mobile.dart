import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../main.dart';
import 'items_mobile.dart';
import 'search_delegate.dart';

class HomeMobile extends StatefulWidget {
  const HomeMobile({super.key});

  @override
  State<HomeMobile> createState() => _HomeMobileState();
}

class _HomeMobileState extends State<HomeMobile> {
  Map<String, dynamic>? categories;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final response = await http.post(Uri.parse('$baseUrl/categories'));
    if (response.statusCode == 200) setState(() => categories = json.decode(response.body));
  }

  @override
  Widget build(BuildContext context) {
    if (categories == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cine DB - Mobile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => showSearch(context: context, delegate: MovieSearchDelegate()),
          )
        ],
      ),
      body: ListView.separated(
        itemCount: categories!.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          String catName = categories!.keys.elementAt(index);
          return ListTile(
            title: Text(catName, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => ItemsMobile(categoryName: catName))
            ),
          );
        },
      ),
    );
  }
}