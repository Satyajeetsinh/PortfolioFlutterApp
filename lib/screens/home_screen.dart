import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './other_profiles.dart';

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
      stream: FirebaseFirestore.instance
          .collection('storage')
          .orderBy("time", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        }
        return _buildList(context, snapshot.data.documents);
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
        key: ValueKey(record.userId),
        child: Container(
          child: Card(
            elevation: 5,
            child: Column(
              children: <Widget>[
                Container(
                  color: Colors.grey[100],
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5),
                    ),
                    child: Image.network(
                      record.url,
                      loadingBuilder: (
                        BuildContext context,
                        Widget child,
                        ImageChunkEvent loadingProcess,
                      ) {
                        if (loadingProcess == null) return child;
                        return Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(),
                        );
                      },
                      height: 450,
                      width: double.infinity,
                      fit: BoxFit.scaleDown,
                      errorBuilder: (context, error, stackTrace) {
                        return Text('Could not download the image, try again');
                      },
                    ),
                  ),
                ),
                ListTile(
                    title: Text(
                      record.userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    subtitle: Text(record.currentTime),
                    trailing: FlatButton(
                      child: Text(
                        'Profile',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side:
                              BorderSide(color: Theme.of(context).accentColor)),
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                            OtherProfileScreen.routeName,
                            arguments: {
                              'id': record.userId,
                              'name': record.userName,
                              'date': record.currentTime,
                            });
                      },
                    )),
              ],
            ),
          ),
        ));
  }
}

class Record {
  final String userName;
  final String url;
  final String currentTime;
  final String userId;
  final String time;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['userName'] != null),
        assert(map['url'] != null),
        assert(map['currentTime'] != null),
        assert(map['userId'] != null),
        assert(map['time'] != null),
        userName = map['userName'],
        url = map['url'],
        userId = map['userId'],
        time = map['time'],
        currentTime = map['currentTime'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data(), reference: snapshot.reference);

  @override
  String toString() => 'Record<$userName:$url:$currentTime:$userId:$time>';
}
