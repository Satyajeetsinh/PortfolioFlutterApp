import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatefulWidget {
  static const routeName = '/contact-screen';

  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  @override
  Widget build(BuildContext context) {
    final routeArg =
        ModalRoute.of(context).settings.arguments as Map<String, String>;

    final id = routeArg['id'];
    final name = routeArg['name'];

    Future<void> userEmail() async {
      return await FirebaseFirestore.instance
          .collection('Users')
          .doc(id)
          .get()
          .then((value) => value.data()['email'].toString());
    }

    Future<void> userPhone() async {
      return await FirebaseFirestore.instance
          .collection('Users')
          .doc(id)
          .get()
          .then((value) => value.data()['phone'].toString());
    }

    String email = '';

    _launchUrl() async {
      final url = Uri.encodeFull(
          'mailto:$email?subject=Photography Portfolio&body=I want to hire you, please contact me back.');
      if (await launch(url)) {
        await launch(url);
      } else {
        Fluttertoast.showToast(
          msg: 'Could not launch $url',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(name + 's' + '' + 'contact details'),
      ),
      body: FutureBuilder(
          future: Future.wait([userEmail(), userPhone()]),
          builder: (context, snapshot) {
            return Container(
              padding: EdgeInsets.all(10),
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        snapshot.hasData ? snapshot.data[0] : 'No email id',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      if (snapshot.data[0] != null)
                        FlatButton.icon(
                          onPressed: () {
                            setState(() {
                              email = snapshot.data[0];
                            });
                            _launchUrl();
                          },
                          icon: Icon(Icons.email),
                          label: Text('Email'),
                        ),
                    ],
                  ),
                ],
              )),
            );
          }),
    );
  }
}
