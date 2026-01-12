import 'package:exercici04/models/background_color.dart';
import 'package:exercici04/models/item_list_model.dart';
import 'package:exercici04/views/categories_list_view.dart';
import 'package:exercici04/views/item_list_view.dart';
import 'package:flutter/material.dart';

void main() {

  const vatfatv = [
    ItemListModel("Reial Club Deportiu Espanyol de Barcelona", BackgroundColor(Color(0xFFE30613), Color(0xFFFFFFF)), "https://upload.wikimedia.org/wikipedia/en/thumb/4/47/FC_Barcelona_%28crest%29.svg/250px-FC_Barcelona_%28crest%29.svg.png", ""),
    ItemListModel("Reial Club Deportiu Espanyol de Barcelona", BackgroundColor(Color(0xFFE30613), Color(0xFFFFFFF)), "https://upload.wikimedia.org/wikipedia/en/thumb/4/47/FC_Barcelona_%28crest%29.svg/250px-FC_Barcelona_%28crest%29.svg.png", ""),
    ItemListModel("Reial Club Deportiu Espanyol de Barcelona", BackgroundColor(Color(0xFFE30613), Color(0xFFFFFFF)), "https://upload.wikimedia.org/wikipedia/en/thumb/4/47/FC_Barcelona_%28crest%29.svg/250px-FC_Barcelona_%28crest%29.svg.png", ""),
    ItemListModel("Reial Club Deportiu Espanyol de Barcelona", BackgroundColor(Color(0xFFE30613), Color(0xFFFFFFF)), "https://upload.wikimedia.org/wikipedia/en/thumb/4/47/FC_Barcelona_%28crest%29.svg/250px-FC_Barcelona_%28crest%29.svg.png", ""),
    ItemListModel("Reial Club Deportiu Espanyol de Barcelona", BackgroundColor(Color(0xFFE30613), Color(0xFFFFFFF)), "https://upload.wikimedia.org/wikipedia/en/thumb/4/47/FC_Barcelona_%28crest%29.svg/250px-FC_Barcelona_%28crest%29.svg.png", ""),
    ItemListModel("Reial Club Deportiu Espanyol de Barcelona", BackgroundColor(Color(0xFFE30613), Color(0xFFFFFFF)), "https://upload.wikimedia.org/wikipedia/en/thumb/4/47/FC_Barcelona_%28crest%29.svg/250px-FC_Barcelona_%28crest%29.svg.png", ""),
    ItemListModel("Reial Club Deportiu Espanyol de Barcelona", BackgroundColor(Color(0xFFE30613), Color(0xFFFFFFF)), "https://upload.wikimedia.org/wikipedia/en/thumb/4/47/FC_Barcelona_%28crest%29.svg/250px-FC_Barcelona_%28crest%29.svg.png", ""),
    ItemListModel("Reial Club Deportiu Espanyol de Barcelona", BackgroundColor(Color(0xFFE30613), Color(0xFFFFFFF)), "https://upload.wikimedia.org/wikipedia/en/thumb/4/47/FC_Barcelona_%28crest%29.svg/250px-FC_Barcelona_%28crest%29.svg.png", ""),
    ItemListModel("Reial Club Deportiu Espanyol de Barcelona", BackgroundColor(Color(0xFFE30613), Color(0xFFFFFFF)), "https://upload.wikimedia.org/wikipedia/en/thumb/4/47/FC_Barcelona_%28crest%29.svg/250px-FC_Barcelona_%28crest%29.svg.png", ""),
    ItemListModel("Reial Club Deportiu Espanyol de Barcelona", BackgroundColor(Color(0xFFE30613), Color(0xFFFFFFF)), "https://upload.wikimedia.org/wikipedia/en/thumb/4/47/FC_Barcelona_%28crest%29.svg/250px-FC_Barcelona_%28crest%29.svg.png", ""),
    ItemListModel("Reial Club Deportiu Espanyol de Barcelona", BackgroundColor(Color(0xFFE30613), Color(0xFFFFFFF)), "https://upload.wikimedia.org/wikipedia/en/thumb/4/47/FC_Barcelona_%28crest%29.svg/250px-FC_Barcelona_%28crest%29.svg.png", ""),
    ItemListModel("Reial Club Deportiu Espanyol de Barcelona", BackgroundColor(Color(0xFFE30613), Color(0xFFFFFFF)), "https://upload.wikimedia.org/wikipedia/en/thumb/4/47/FC_Barcelona_%28crest%29.svg/250px-FC_Barcelona_%28crest%29.svg.png", ""),
    ItemListModel("Reial Club Deportiu Espanyol de Barcelona", BackgroundColor(Color(0xFFE30613), Color(0xFFFFFFF)), "https://upload.wikimedia.org/wikipedia/en/thumb/4/47/FC_Barcelona_%28crest%29.svg/250px-FC_Barcelona_%28crest%29.svg.png", ""),
    ItemListModel("Reial Club Deportiu Espanyol de Barcelona", BackgroundColor(Color(0xFFE30613), Color(0xFFFFFFF)), "https://upload.wikimedia.org/wikipedia/en/thumb/4/47/FC_Barcelona_%28crest%29.svg/250px-FC_Barcelona_%28crest%29.svg.png", ""),
    ItemListModel("Reial Club Deportiu Espanyol de Barcelona", BackgroundColor(Color(0xFFE30613), Color(0xFFFFFFF)), "https://upload.wikimedia.org/wikipedia/en/thumb/4/47/FC_Barcelona_%28crest%29.svg/250px-FC_Barcelona_%28crest%29.svg.png", ""),
    ItemListModel("Reial Club Deportiu Espanyol de Barcelona", BackgroundColor(Color(0xFFE30613), Color(0xFFFFFFF)), "https://upload.wikimedia.org/wikipedia/en/thumb/4/47/FC_Barcelona_%28crest%29.svg/250px-FC_Barcelona_%28crest%29.svg.png", ""),
    ItemListModel("Reial Club Deportiu Espanyol de Barcelona", BackgroundColor(Color(0xFFE30613), Color(0xFFFFFFF)), "https://upload.wikimedia.org/wikipedia/en/thumb/4/47/FC_Barcelona_%28crest%29.svg/250px-FC_Barcelona_%28crest%29.svg.png", ""),
    ItemListModel("Reial Club Deportiu Espanyol de Barcelona", BackgroundColor(Color(0xFFE30613), Color(0xFFFFFFF)), "https://upload.wikimedia.org/wikipedia/en/thumb/4/47/FC_Barcelona_%28crest%29.svg/250px-FC_Barcelona_%28crest%29.svg.png", ""),
    ItemListModel("Reial Club Deportiu Espanyol de Barcelona", BackgroundColor(Color(0xFFE30613), Color(0xFFFFFFF)), "https://upload.wikimedia.org/wikipedia/en/thumb/4/47/FC_Barcelona_%28crest%29.svg/250px-FC_Barcelona_%28crest%29.svg.png", ""),
    ItemListModel("Reial Club Deportiu Espanyol de Barcelona", BackgroundColor(Color(0xFFE30613), Color(0xFFFFFFF)), "https://upload.wikimedia.org/wikipedia/en/thumb/4/47/FC_Barcelona_%28crest%29.svg/250px-FC_Barcelona_%28crest%29.svg.png", ""),
    ItemListModel("Reial Club Deportiu Espanyol", BackgroundColor(Color(0xFFE30613), Color(0xFFFFFFF)), "https://upload.wikimedia.org/wikipedia/en/thumb/4/47/FC_Barcelona_%28crest%29.svg/250px-FC_Barcelona_%28crest%29.svg.png", "")
  ];

  runApp(const MyApp(items: vatfatv));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.items});

  final List<ItemListModel> items;

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
      home: CategoriesListView(items: items)
    );
  }
}