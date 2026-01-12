import 'package:exercici04/models/item_list_model.dart';
import 'package:exercici04/views/categories_item_list_view.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Importación corregida
import 'dart:convert';

class CategoriesWindow extends StatefulWidget {
  const CategoriesWindow({super.key});

  @override
  State<CategoriesWindow> createState() => _CategoriesWindowState();
}

class _CategoriesWindowState extends State<CategoriesWindow> {
  late Future<List<ItemListModel>> _futureItems;

  @override
  void initState() {
    super.initState();
    _futureItems = makePostRequest();
  }

  Future<List<ItemListModel>> makePostRequest() async {
    final url = Uri.parse('http://localhost:3000/categories'); //
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'key': 'value', 
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedData = jsonDecode(response.body); //
      
      List<ItemListModel> items = [];
      decodedData.forEach((key, value) {
        items.add(ItemListModel.fromJson(key, value));
      });
      
      return items;
    } else {
      throw Exception('Error al obtener datos mediante POST: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("LaLiga Categories")),
      body: FutureBuilder<List<ItemListModel>>(
        future: _futureItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final items = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0), // Margen a los lados
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 10),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0), // Margen entre items
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0), // Bordes redondeados del item
                    child: CatergoriesItemListView(data: items[index]),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}