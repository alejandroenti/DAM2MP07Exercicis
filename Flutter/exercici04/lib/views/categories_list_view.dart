import 'package:exercici04/models/item_list_model.dart';
import 'package:exercici04/views/item_list_view.dart';
import 'package:flutter/material.dart';



class CategoriesListView extends StatelessWidget {

  final List<ItemListModel> items;

  const CategoriesListView({super.key, required this.items});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ItemListView(data: items[index]);
        },
      ),
    );
  }

  List<ItemListView> createItemsList() {

    var itemsWidgets = <ItemListView>[];

    for (var i = 0; i < items.length; i++) {
      var item = items[i];
      itemsWidgets.add(ItemListView(data: item));
    }
    return itemsWidgets;
  }

}