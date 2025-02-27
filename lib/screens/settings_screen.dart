import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings ⚙️")),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Choose a Theme:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: const Text("Cute 🌸"),
            leading: const Icon(Icons.favorite, color: Colors.pink),
            trailing: themeProvider.currentTheme == AppTheme.cute
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () => themeProvider.setTheme(AppTheme.cute),
          ),
          ListTile(
            title: const Text("Gothic 🖤"),
            leading: const Icon(Icons.nights_stay, color: Colors.black),
            trailing: themeProvider.currentTheme == AppTheme.gothic
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () => themeProvider.setTheme(AppTheme.gothic),
          ),
          ListTile(
            title: const Text("Goofy 🤪"),
            leading: const Icon(Icons.emoji_emotions, color: Colors.yellow),
            trailing: themeProvider.currentTheme == AppTheme.goofy
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () => themeProvider.setTheme(AppTheme.goofy),
          ),
        ],
      ),
    );
  }
}
