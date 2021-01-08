import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = '/profile-screen';
  @override
  Widget build(BuildContext context) {
    final routeArg =
        ModalRoute.of(context).settings.arguments as Map<String, String>;
    final id = routeArg['id'];
    final name = routeArg['name'];
    final removeChar = name.replaceAll(new RegExp(r'[^\w\s]+'), '');
    return Scaffold(
      appBar: AppBar(
        title: Text(removeChar),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Text('Description'),
            Divider(),
            Container(
              child: SingleChildScrollView(
                child: Text('photos'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
