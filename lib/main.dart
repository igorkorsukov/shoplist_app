import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'shoplist_screen.dart';
import 'additem_screen.dart';
import 'store.dart';
import 'types.dart';

// YA_DISK_DEV_TOKEN

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shoplist',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      initialRoute: '/shoplist',
      routes: {
        '/shoplist': (context) => ShopListScreen(),
        '/additem': (context) => AddItemScreen(),
      },
    );
  }
}
