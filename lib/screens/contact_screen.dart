import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatelessWidget {
  static const routeName = '/contact-screen';

  final String id;

  ContactScreen({this.id});

  Future<void> getEmail() async {
    return await FirebaseFirestore.instance
        .collection('Users')
        .doc(id)
        .get()
        .then((value) => value.data()['email'].toString());
  }

  Future<void> getPhone() async {
    return await FirebaseFirestore.instance
        .collection('Users')
        .doc(id)
        .get()
        .then((value) => value.data()['phone'].toString());
  }

  _launchEmail(String email) async {
    final url =
        'mailto:$email?subject=Photography Portfolio&body=I want to hire you, please contact me back.';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not email $url';
    }
  }

  _launchPhone(String phone) async {
    final url = 'tel://$phone';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not call $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([getEmail(), getPhone()]),
      builder: (context, snapshot) => SingleChildScrollView(
        child: Card(
          elevation: 5,
          child: Container(
            padding: EdgeInsets.only(
              top: 10,
              left: 10,
              right: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(snapshot.hasData
                        ? snapshot.data[0]
                        : 'No email available'),
                    IconButton(
                        icon: Icon(Icons.email),
                        onPressed: () {
                          _launchEmail(snapshot.data[0]);
                        }),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(snapshot.hasData
                        ? snapshot.data[1]
                        : 'Number not available'),
                    IconButton(
                        icon: Icon(Icons.call),
                        onPressed: () {
                          _launchPhone(snapshot.data[1]);
                        }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
