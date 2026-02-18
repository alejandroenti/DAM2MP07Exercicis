import 'package:flutter/material.dart';
import 'views/home_desktop.dart';
import 'views/home_mobile.dart';

void main() => runApp(const CineApp());

const String baseUrl = "https://alopezhuesca.ieti.site";

class CineApp extends StatelessWidget {
  const CineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cine DB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), 
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white, 
          elevation: 4, 
        ),
      ),
      home: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return const HomeDesktop();
          } else {
            return const HomeMobile();
          }
        },
      ),
    );
  }
}