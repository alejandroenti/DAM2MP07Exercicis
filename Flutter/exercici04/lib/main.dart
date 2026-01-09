import 'package:exercici04/models/background_color.dart';
import 'package:exercici04/models/item_list_model.dart';
import 'package:exercici04/views/item_list_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LaLiga DB',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.red),
        useMaterial3: true
      ),
      home: ItemListView(data: ItemListModel("Reial Club Deportiu Espanyol de Barcelona", BackgroundColor(Color(0xFFE30613), Color(0xFFFFFFF)), "https://upload.wikimedia.org/wikipedia/en/thumb/4/47/FC_Barcelona_%28crest%29.svg/250px-FC_Barcelona_%28crest%29.svg.png", ""))
    );
  }
}