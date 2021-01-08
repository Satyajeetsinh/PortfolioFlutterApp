import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home-screen';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[Flexible(child: _buildBody(context))],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('storage').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        }
        return snapshot.connectionState == ConnectionState.waiting
            ? Center(child: CircularProgressIndicator())
            : _buildList(context, snapshot.data.documents);
      },
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
      padding: const EdgeInsets.all(5),
      key: ValueKey(record.location),
      child: Container(
          child: Card(
        elevation: 5,
        child: Column(
          children: <Widget>[
            Image.network(
              record.url,
              fit: BoxFit.scaleDown,
            ),
            ListTile(
              title: Text(
                record.location,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              subtitle: Text(record.currentTime),
            )
          ],
        ),
      )),
    );
  }
}

class Record {
  final String location;
  final String url;
  final String currentTime;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['location'] != null),
        assert(map['url'] != null),
        assert(map['currentTime'] != null),
        location = map['location'],
        url = map['url'],
        currentTime = map['currentTime'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data(), reference: snapshot.reference);

  @override
  String toString() => 'Record<$location:$url:$currentTime>';
}
