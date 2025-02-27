import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const LoveBirdApp(),
    ),);
}

class LoveBirdApp extends StatelessWidget {
  const LoveBirdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: "LoverBird",
          theme: themeProvider.themeData,
          home: const HomeScreen(), // Change to your home screen if needed
        );
      },
    );
  }
}
