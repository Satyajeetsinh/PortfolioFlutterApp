import 'package:flutter/material.dart';

class MessagesScreen extends StatefulWidget {
  static const routeName = '/messages-screen';
  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
    );
  }
}
