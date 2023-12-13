import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'infrastructure/modularity/modulesetup.dart';
import 'infrastructure/infrastructuremodule.dart';
import 'shoplist/shoplistmodule.dart';

import 'shoplist/view/perform_screen.dart';
import 'shoplist/view/edit_screen.dart';

// flutter build apk --split-per-abi

void main() async {
  await dotenv.load(fileName: ".env");

  final List<ModuleSetup> modules = [InfrastructureModule(), ShopListModule()];
  for (var m in modules) {
    m.registerExports();
  }

  for (var m in modules) {
    m.resolveImports();
  }

  for (var m in modules) {
    m.onInit();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ColorScheme colors = ColorScheme.fromSeed(seedColor: Colors.green);

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
        '/edititems': (context) => const EditListScreen(),
      },
    );
  }
}
