import 'package:flutter/material.dart';
import '../widgets/messages.dart';
import 'package:intl/intl.dart';

class MessagesScreen extends StatefulWidget {
  static const routeName = '/messages-screen';
  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final date = DateFormat.yMMMd().format(DateTime.now());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: GestureDetector(
        child: Card(
          child: ListTile(
            leading: Icon(Icons.person),
            title: Text('Name'),
            subtitle: Text('click to open chat'),
          ),
          elevation: 5,
        ),
        onTap: () {
          Navigator.of(context).pushNamed(Messages.routeName);
        },
      ),
    );
  }
}
