import 'package:flutter/material.dart';
import 'messages_screen.dart';
import 'notes_screen.dart';
import 'meme_screen.dart';
import 'doodle_screen.dart';
import 'settings_screen.dart';
import 'gallery_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LoveBird App 🦜')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          _buildMenuButton(context, 'Daily Messages', Icons.favorite, MessagesScreen()),
          _buildMenuButton(context, 'Notes', Icons.note, NotesScreen()),
          _buildMenuButton(context, 'Meme Mode', Icons.mood, MemeScreen()),
          _buildMenuButton(context, 'Doodle Pad', Icons.brush, DoodleScreen()),
          _buildMenuButton(context, "Gallery", Icons.collections, GalleryScreen()),
          _buildMenuButton(context, 'Settings', Icons.settings, SettingsScreen()),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, IconData icon, Widget screen) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => screen)),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.redAccent),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
