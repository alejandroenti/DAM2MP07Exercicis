import 'package:exercici04/models/item_list_model.dart';
import 'package:exercici04/views/categories_item_list_view.dart';
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
          return CatergoriesItemListView(data: items[index]);
        },
      ),
    );
  }

  List<CatergoriesItemListView> createItemsList() {

    var itemsWidgets = <CatergoriesItemListView>[];

    for (var i = 0; i < items.length; i++) {
      var item = items[i];
      itemsWidgets.add(CatergoriesItemListView(data: item));
    }
    return itemsWidgets;
  }

}