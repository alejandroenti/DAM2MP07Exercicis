import 'package:exercici04/models/background_color.dart';

class ItemListModel {
  final String name;
  final BackgroundColor colors;
  final String imageUrl;
  final String number;

  const ItemListModel(this.name, this.colors, this.imageUrl, this.number);
}