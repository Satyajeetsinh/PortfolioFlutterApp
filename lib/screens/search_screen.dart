import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import './other_profiles.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/search-screen';
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String name = 'test';
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
              child: Text('Search'),
            )
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .where('username', isEqualTo: name)
                  .where('userId')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.data == null) return CircularProgressIndicator();

                var username = snapshot.data.documents.map<String>(
                  (doc) {
                    displayUserName = doc['username'].toString();
                    return displayUserName;
                  },
                );

                var id = snapshot.data.documents.map<String>(
                  (id) {
                    userId = id['userId'].toString();
                    return userId;
                  },
                );

                var emailId = snapshot.data.documents.map<String>(
                  (emailId) {
                    email = emailId['email'].toString();
                    return email;
                  },
                );

                if (username.toString() == null ||
                    username.toString() == ('()') ||
                    id.toString() == null ||
                    id.toString() == ('()') ||
                    email.toString() == null ||
                    email.toString() == ('()'))
                  return Center(
                    child: Text(
                      'User not available',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );

                return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (ctx, index) {
                    return Column(
                      children: <Widget>[
                        Card(
                          key: ValueKey(UniqueKey),
                          elevation: 5,
                          child: ListTile(
                            leading: Icon(Icons.person),
                            title: Text(displayUserName),
                            subtitle: Text(email),
                            trailing: FlatButton(
                              child: Text(
                                'Profile',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                      color: Theme.of(context).accentColor)),
                              onPressed: () {
                                Navigator.of(context).pushNamed(
                                  OtherProfileScreen.routeName,
                                  arguments: {
                                    'id': userId,
                                    'name': displayUserName,
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
    );
  }
}
