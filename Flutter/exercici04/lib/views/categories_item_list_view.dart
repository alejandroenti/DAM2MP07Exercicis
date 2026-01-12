import 'package:exercici04/models/item_list_model.dart';
import 'package:flutter/material.dart';

class CatergoriesItemListView extends StatelessWidget {

  final ItemListModel data;

  const CatergoriesItemListView({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [data.colors.mainColor, data.colors.secondaryColor],
        ),
      ),
      child: Row(
        children: <Widget>[
          const SizedBox(width: 20),
          Image.network(
            data.imageUrl,
            width: 80,
            height: 80,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 20),
          Text(
            data.number,
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              data.name,
              style: const TextStyle(fontSize: 20),
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
    );
  }

}