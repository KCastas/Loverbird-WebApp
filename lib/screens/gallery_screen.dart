import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<String> _favoriteImages = [];
  Map<String, List<File>> _challengeImages = {};

  @override
  void initState() {
    super.initState();
    _loadGallery();
  }

  Future<void> _loadGallery() async {
  final directory = await getApplicationDocumentsDirectory();
  List<FileSystemEntity> challengeFolders = directory.listSync();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  List<String> savedFavorites = prefs.getStringList('favoriteImages') ?? [];

  Map<String, List<File>> tempImages = {};

  for (var folder in challengeFolders) {
    if (folder is Directory) {
      String challengeName = folder.path.split('/').last.replaceAll('_', ' ');
      List<File> images = folder.listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.png'))
          .toList();

      tempImages[challengeName] = images;
    }
  }

  setState(() {
    _challengeImages = tempImages;
    _favoriteImages = savedFavorites;
  });
  }

  void _toggleFavorite(File imageFile) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String imagePath = imageFile.path;

  setState(() {
    if (_favoriteImages.contains(imagePath)) {
      _favoriteImages.remove(imagePath);
    } else {
      _favoriteImages.add(imagePath);
    }
  });

  await prefs.setStringList('favoriteImages', _favoriteImages);
  }

  void _shareImage(File imageFile) async {
  try {
    await Share.shareXFiles([XFile(imageFile.path)], text: "Check out my drawing! 🎨");
  } catch (e) {
    print("Error sharing image: $e");
  }
  }

  void _deleteImage(File imageFile) async {
  bool? confirmDelete = await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Delete Drawing?"),
        content: Text("Are you sure you want to delete this drawing? This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );

  if (confirmDelete == true) {
    try {
      await imageFile.delete();
      _loadGallery(); // Refresh gallery
      Navigator.pop(context); // Close image dialog
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Drawing deleted!")));
    } catch (e) {
      print("Error deleting image: $e");
    }
  }
  }



  void _openImage(File imageFile) {
  bool isFavorite = _favoriteImages.contains(imageFile.path);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(imageFile, fit: BoxFit.cover),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.favorite, color: isFavorite ? Colors.red : Colors.grey),
                  onPressed: () {
                    _toggleFavorite(imageFile);
                    Navigator.pop(context);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.share, color: Colors.blue),
                  onPressed: () => _shareImage(imageFile),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteImage(imageFile),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text("Drawing Gallery 🎨")),
    body: _challengeImages.isEmpty && _favoriteImages.isEmpty
        ? const Center(child: Text("No saved drawings yet."))
        : ListView(
            children: [
              if (_favoriteImages.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("⭐ Favorites", 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                      itemCount: _favoriteImages.length,
                      itemBuilder: (context, index) {
                        File favoriteFile = File(_favoriteImages[index]);
                        return GestureDetector(
                          onTap: () => _openImage(favoriteFile),
                          child: Image.file(favoriteFile, fit: BoxFit.cover),
                        );
                      },
                    ),
                  ],
                ),
              ..._challengeImages.entries.map((entry) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(entry.key, 
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        itemCount: entry.value.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => _openImage(entry.value[index]),
                            child: Image.file(entry.value[index], fit: BoxFit.cover),
                          );
                        },
                      ),
                    ],
                  ))
            ],
          ),
  );
  }
}

class FullScreenImage extends StatelessWidget {
  final File imageFile;

  const FullScreenImage({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(),
      body: Center(child: Image.file(imageFile)),
    );
  }
}
