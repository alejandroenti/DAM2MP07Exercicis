import 'package:exercici04/models/item_list_model.dart';
import 'package:flutter/material.dart';

class ItemListView extends StatelessWidget {

  final ItemListModel data;

  const ItemListView({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                data.colors.mainColor,
                data.colors.secondaryColor
              ]
            )
          ),

          child: Row(
          children: <Widget>[
            Padding(padding: EdgeInsetsGeometry.only(right:30)),
            Image(
              image: NetworkImage(data.imageUrl),
              width: 100,
              height: 100,
              fit:BoxFit.fill
            ),
            Padding(padding: EdgeInsetsGeometry.only(right:10)),
            Text(
              data.number,
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.black
              ) 
            ),
            Padding(padding: EdgeInsetsGeometry.only(right:15)),
            Text(
              data.name,
              style: TextStyle(
                fontSize: 36,
                color: Colors.black
              ),
            )            
          ],
        )
      )
        ),
      );
  }

}