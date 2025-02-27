import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/stroke.dart';
import '../data/challenges.dart';

class DoodleScreen extends StatefulWidget {
  const DoodleScreen({super.key});

  @override
  _DoodleScreenState createState() => _DoodleScreenState();
}

class _DoodleScreenState extends State<DoodleScreen> {
  List<Stroke> _strokes = [];
  List<Stroke> _redoStack = []; // Stores undone strokes for redo
  List<Offset> _currentStroke = [];
  Color _selectedColor = Colors.black;
  double _brushSize = 4.0;
  GlobalKey _repaintKey = GlobalKey(); // Key for capturing the widget
  File? _backgroundImage; // Store the selected image

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _backgroundImage = File(pickedFile.path);
      });
    }
  }

  String _currentChallenge = "Tap the 🎯 button to get a challenge!";

  void _generateChallenge() {
    setState(() {
      _currentChallenge = DrawingChallenges.getRandomChallenge();
    });
  }

  void _clearCanvas() {
    setState(() {
      _strokes.clear();
      _redoStack.clear(); // Reset redo stack too
    });
  }

  void _undo() {
    if (_strokes.isNotEmpty) {
      setState(() {
        _redoStack.add(_strokes.removeLast()); // Move last stroke to redo stack
      });
    }
  }

  void _redo() {
    if (_redoStack.isNotEmpty) {
      setState(() {
        _strokes.add(_redoStack.removeLast()); // Move last undone stroke back to strokes
      });
    }
  }


  Future<void> _saveDrawing({bool share = false}) async {
  try {
    RenderRepaintBoundary? boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;

    var image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    final directory = await getApplicationDocumentsDirectory();
    String sanitizedChallenge = _currentChallenge.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
    String challengeFolderPath = '${directory.path}/$sanitizedChallenge';

    // Create folder for challenge if it doesn't exist
    Directory challengeFolder = Directory(challengeFolderPath);
    if (!challengeFolder.existsSync()) {
      challengeFolder.createSync(recursive: true);
    }

    // Save drawing in challenge folder
    String filePath = '$challengeFolderPath/doodle_${DateTime.now().millisecondsSinceEpoch}.png';
    File imgFile = File(filePath);
    await imgFile.writeAsBytes(pngBytes);

    if (share) {
      await Share.shareXFiles([XFile(filePath)], text: "I completed the challenge: $_currentChallenge! 🎨");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saved to gallery!")),
      );
    }
  } catch (e) {
    print("Error saving image: $e");
  }
}


  void _shareDrawing() => _saveDrawing(share: true);

  void _startStroke(DragStartDetails details) {
    RenderBox object = context.findRenderObject() as RenderBox;
    Offset localPosition = object.globalToLocal(details.globalPosition);

    setState(() {
    _currentStroke = [adjustOffset(localPosition)];
    _redoStack.clear(); // Reset redo when new stroke starts
    });
  }

 void _updateStroke(DragUpdateDetails details) {
  RenderBox object = context.findRenderObject() as RenderBox;
  Offset localPosition = object.globalToLocal(details.globalPosition);

  setState(() {
    _currentStroke.add(adjustOffset(localPosition));
  });
  }

  // Fix Y-axis offset
  Offset adjustOffset(Offset position) {
    double appBarHeight = kToolbarHeight; // Default AppBar height
    double toolBarHeight = 50; // Approximate toolbar height

    return Offset(position.dx, position.dy - appBarHeight - toolBarHeight);
  }

  void _endStroke(DragEndDetails details) {
    setState(() {
      _strokes.add(
        Stroke(
          points: List.from(_currentStroke), // Save completed stroke
          color: _selectedColor,
          brushSize: _brushSize,
        ),
      );
      _currentStroke.clear(); // Reset the temporary stroke list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Doodle Pad 🎨")),
      body: Column(
        children: [
          _buildToolBar(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _currentChallenge,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: RepaintBoundary(
              key: _repaintKey,
              child: Stack(
                children: [
                  if (_backgroundImage != null) 
                    Positioned.fill(
                      child: Image.file(_backgroundImage!, fit: BoxFit.cover),
                    ),
                  GestureDetector(
                    onPanStart: _startStroke,
                    onPanUpdate: _updateStroke,
                    onPanEnd: _endStroke,
                    child: CustomPaint(
                      painter: DoodlePainter(_strokes, _currentStroke, _selectedColor, _brushSize),
                      size: Size.infinite,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _generateChallenge,
            child: const Icon(Icons.emoji_objects),
            tooltip: "Get a Drawing Challenge!",
          ),
          FloatingActionButton(
            onPressed: _pickImageFromGallery,
            child: const Icon(Icons.photo_library),
            tooltip: "Pick Image from Gallery",
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _takePhoto,
            child: const Icon(Icons.camera_alt),
            tooltip: "Take a Photo",
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _undo,
            child: const Icon(Icons.undo),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _redo,
            child: const Icon(Icons.redo),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _saveDrawing,
            child: const Icon(Icons.save),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _shareDrawing,
            child: const Icon(Icons.share),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _clearCanvas,
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }

  Widget _buildToolBar() {
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          DropdownButton<double>(
            dropdownColor: Colors.black,
            value: _brushSize,
            icon: const Icon(Icons.brush, color: Colors.white),
            items: [2.0, 4.0, 6.0, 8.0, 10.0]
                .map((size) => DropdownMenuItem(
                      value: size,
                      child: Text("Size $size", style: const TextStyle(color: Colors.white)),
                    ))
                .toList(),
            onChanged: (newSize) {
              setState(() {
                _brushSize = newSize!;
              });
            },
          ),
          ElevatedButton(
            onPressed: () async {
              Color? pickedColor = await _showColorPicker(context, _selectedColor);
              if (pickedColor != null) {
                setState(() {
                  _selectedColor = pickedColor;
                });
              }
            },
            child: const Text("Pick Color"),
          ),
        ],
      ),
    );
  }

  Future<Color?> _showColorPicker(BuildContext context, Color currentColor) async {
    return showDialog<Color>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select a Color"),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: currentColor,
              onColorChanged: (color) {
                Navigator.pop(context, color);
              },
            ),
          ),
        );
      },
    );
  }

  void _pickImageFromGallery() => _pickImage(ImageSource.gallery);
  void _takePhoto() => _pickImage(ImageSource.camera);
}

// Custom Painter for Drawing
class DoodlePainter extends CustomPainter {
  final List<Stroke> strokes;
  final List<Offset> currentStroke;
  final Color currentColor;
  final double currentBrushSize;

  DoodlePainter(this.strokes, this.currentStroke, this.currentColor, this.currentBrushSize);

  @override
  void paint(Canvas canvas, Size size) {
    // **Fill the canvas with white before drawing**
    Paint backgroundPaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // **Draw all previous strokes**
    for (var stroke in strokes) {
      Paint paint = Paint()
        ..color = stroke.color
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke.brushSize;

      for (int i = 0; i < stroke.points.length - 1; i++) {
        if (stroke.points[i] != null && stroke.points[i + 1] != null) {
          canvas.drawLine(stroke.points[i], stroke.points[i + 1], paint);
        }
      }
    }

    // **Draw the current stroke separately**
    Paint paint = Paint()
      ..color = currentColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = currentBrushSize;

    for (int i = 0; i < currentStroke.length - 1; i++) {
      canvas.drawLine(currentStroke[i], currentStroke[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(DoodlePainter oldDelegate) => true;
}

