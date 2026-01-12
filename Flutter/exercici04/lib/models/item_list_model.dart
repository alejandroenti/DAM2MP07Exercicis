// lib/models/item_list_model.dart
import 'package:exercici04/models/background_color.dart';
import 'package:flutter/material.dart';

class ItemListModel {
  final String name;
  final BackgroundColor colors;
  final String imageUrl;
  final String number;

  const ItemListModel(this.name, this.colors, this.imageUrl, this.number);

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  factory ItemListModel.fromJson(String key, Map<String, dynamic> json) {
    List<dynamic> bg = json['background'];
    return ItemListModel(
      json['fullName'] ?? key,
      BackgroundColor(fromHex(bg[0]), fromHex(bg[1])),
      "http://localhost:3000${json['image']}",
      "",
    );
  }
}