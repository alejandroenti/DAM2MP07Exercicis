import 'package:exercici04/models/background_color.dart';

class ItemListModel {
  final String name;
  final BackgroundColor colors;
  final String imageUrl;
  final String number;

  ItemListModel(this.name, this.colors, this.imageUrl, this.number);
}