import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = '/profile-screen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
