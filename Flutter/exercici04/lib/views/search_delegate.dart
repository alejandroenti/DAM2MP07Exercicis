import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../main.dart';
import 'detail_view.dart';

class MovieSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = "")
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

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
            onTap: () {
              final isDesktop = MediaQuery.of(context).size.width > 800;
              if (isDesktop) {
                close(context, results[index]);
              } else {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(title: const Text("Detalle")),
                    body: ItemDetailView(item: results[index]),
                  )
                ));
              }
            },
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) => const SizedBox();
}