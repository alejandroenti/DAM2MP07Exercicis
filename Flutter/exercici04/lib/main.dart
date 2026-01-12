import 'package:exercici04/views/categories_window.dart';
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
      home: CategoriesWindow()
    );
  }
}