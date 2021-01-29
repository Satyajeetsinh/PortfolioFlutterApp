import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/search-screen';
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String name;
  String userId;
  String displayUserName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          cursorColor: Colors.white,
          onSubmitted: (val) {
            setState(() {
              name = val;
            });
          },
          style: TextStyle(fontSize: 18, color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search here....',
            hintStyle: TextStyle(color: Colors.white),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .where('username', isEqualTo: name)
            .where('userId')
            .snapshots(),
        builder: (context, snapshot) {
          var username = snapshot.data.documents.map<String>(
            (doc) {
              displayUserName = doc['username'].toString();
              return doc['username'].toString();
            },
          );
          var id = snapshot.data.documents.map<String>(
            (id) {
              userId = id['userId'].toString();
              return id['userId'].toString();
            },
          );

          if (!snapshot.hasData) {
            return Text('No data found');
          }
          return Center(
            child: ListView(
              children: <Widget>[
                username.toString() == null ||
                        username.toString() == ('()') ||
                        id.toString() == null ||
                        id.toString() == ('()')
                    ? Text('User not available')
                    : Text(displayUserName != null || userId != null
                        ? displayUserName + ' ' + userId
                        : 'Searching'),
              ],
            ),
          );
        },
      ),
    );
  }
}
