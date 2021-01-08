import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainDrawer extends StatefulWidget {
  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  Widget bottomListTile(String title, IconData icon, Function tapHandler) {
    return ListTile(
      leading: Icon(
        icon,
        size: 26,
        color: Colors.white,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: tapHandler,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;
    final User user = auth.currentUser;

    Future<void> userName() async {
      return await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get()
          .then((value) => value.data()['username'].toString());
    }

    Future<void> userEmail() async {
      return await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get()
          .then((value) => value.data()['email'].toString());
    }

    return FutureBuilder(
      future: Future.wait([userName(), userEmail()]),
      builder: (ctx, snapshot) => Drawer(
        child: Column(
          children: <Widget>[
            Container(
              height: 250,
              width: double.infinity,
              padding: EdgeInsets.all(20),
              alignment: Alignment.bottomLeft,
              color: Theme.of(context).primaryColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    snapshot.hasData ? snapshot.data[0] : 'Name',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    snapshot.hasData ? snapshot.data[1] : 'email',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.edit),
                    title: Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            Container(
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: Container(
                  color: Theme.of(context).primaryColor,
                  child: Column(
                    children: <Widget>[
                      bottomListTile(
                        'Log Out',
                        Icons.logout,
                        () {
                          FirebaseAuth.instance.signOut();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
