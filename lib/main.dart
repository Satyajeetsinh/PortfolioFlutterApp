import 'package:flutter/material.dart';

import './screens/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portfolio',
      initialRoute: '/',
      routes: {
        '/': (ctx) => HomeScreen(),
      },
    );
  }
}
