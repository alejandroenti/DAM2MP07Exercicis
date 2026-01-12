// lib/views/categories_item_list_view.dart
import 'package:exercici04/models/item_list_model.dart';
import 'package:flutter/material.dart';

class CatergoriesItemListView extends StatelessWidget {
  final ItemListModel data;

  const CatergoriesItemListView({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [data.colors.mainColor, data.colors.secondaryColor],
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              data.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.shield, size: 50),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              data.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}