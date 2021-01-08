import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = '/profile-screen';
  @override
  Widget build(BuildContext context) {
    final routeArg =
        ModalRoute.of(context).settings.arguments as Map<String, String>;
    final id = routeArg['id'];
    final name = routeArg['name'];
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
    );
  }
}
