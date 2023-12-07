import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'shoplist/view/shoplist_screen.dart';
import 'shoplist/view/add_screen.dart';
import 'shoplist/services/shoplsitrepository.dart';
import 'sync/services/sync.dart';
import 'infrastructure/db/localstorage.dart';

void main() async {
  await dotenv.load(fileName: ".env");

  LocalStorage.instance().init();

  ShopListRepository.instance.init();

  Sync.instance.init();
  Sync.instance.startSync();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ColorScheme colors = ColorScheme.fromSeed(seedColor: Colors.teal);

    return MaterialApp(
      title: 'Shoplist',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colors,
        appBarTheme: AppBarTheme(
            backgroundColor: colors.primary,
            // This will be applied to the "back" icon
            iconTheme: const IconThemeData(color: Colors.white),
            // This will be applied to the action icon buttons that locates on the right side
            actionsIconTheme: const IconThemeData(color: Colors.white),
            // centerTitle: false,
            // elevation: 15,
            titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20)),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/shoplist',
      routes: {
        '/shoplist': (context) => const ShopListScreen(),
        '/additems': (context) => const AddItemScreen(),
      },
    );
  }
}
