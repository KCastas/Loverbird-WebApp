import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref("messages");
  String _dailyMessage = "Fetching message...";

  @override
  void initState() {
    super.initState();
    _fetchRandomMessage();
  }

  void _fetchRandomMessage() async {
    DatabaseEvent event = await _databaseRef.once();
    Map<dynamic, dynamic>? messages = event.snapshot.value as Map?;
    if (messages != null) {
      List<String> messageList = messages.values.cast<String>().toList();
      setState(() {
        _dailyMessage = messageList[Random().nextInt(messageList.length)];
      });
    } else {
      setState(() {
        _dailyMessage = "No messages available.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Message')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            _dailyMessage,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
