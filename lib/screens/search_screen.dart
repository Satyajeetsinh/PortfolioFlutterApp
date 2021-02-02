import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import './other_profiles.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/search-screen';
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String name = '';
  String userId;
  String displayUserName;
  bool search = false;
  String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          cursorColor: Colors.white,
          onSubmitted: (val) {
            setState(() {
              name = val;
              search = true;
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
      body: search == false
          ? Center(
              child: Text(
                'Search Users',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            )
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .where('username', isEqualTo: name)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(
                    child: CircularProgressIndicator(),
                  );

                return snapshot.data.documents.toString() == '[]'
                    ? Center(
                        child: Text(
                          'User not available',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      )
                    : _buildList(context, snapshot.data.documents);
              },
            ),
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);

    return Padding(
      padding: EdgeInsets.all(5),
      key: ValueKey(record.userId),
      child: Container(
        child: Card(
          elevation: 5,
          child: ListTile(
            title: Text(record.username),
            subtitle: Text(record.email),
            trailing: FlatButton(
              child: Text(
                'Profile',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Theme.of(context).accentColor)),
              onPressed: () {
                Navigator.of(context).pushNamed(
                  OtherProfileScreen.routeName,
                  arguments: {
                    'id': record.userId,
                    'name': record.username,
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class Record {
  final String username;
  final String userId;
  final DocumentReference reference;
  final String email;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['username'] != null),
        assert(map['userId'] != null),
        assert(map['email'] != null),
        username = map['username'],
        email = map['email'],
        userId = map['userId'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data(), reference: snapshot.reference);

  @override
  String toString() => 'Record<$username:$userId:$email>';
}
