import 'package:flutter/material.dart';
import 'dart:math';

class MemeScreen extends StatefulWidget {
  const MemeScreen({super.key});

  @override
  _MemeScreenState createState() => _MemeScreenState();
}

class _MemeScreenState extends State<MemeScreen> {
  // Predefined set of memes or jokes for now
  final List<String> _memes = [
    'Why don’t skeletons fight each other? They don’t have the guts.',
    'I told my wife she was drawing her eyebrows too high. She looked surprised.',
    'Parallel lines have so much in common. It’s a shame they’ll never meet.',
    'I told my computer I needed a break, and now it won’t stop sending me Kit-Kats.',
    'How does a penguin build its house? Igloos it together.',
  ];

  String _currentMeme = "Tap the button for a meme!";

  void _getRandomMeme() {
    setState(() {
      _currentMeme = _memes[Random().nextInt(_memes.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meme Mode")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _currentMeme,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _getRandomMeme,
                child: const Text("Get Random Meme"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
