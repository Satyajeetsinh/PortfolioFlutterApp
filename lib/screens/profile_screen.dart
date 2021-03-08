import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/profile_photo.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile-screen';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User user = FirebaseAuth.instance.currentUser;
  String userName;
  String emailId;
  String description;

  getUsernameEmail() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    setState(() {
      userName = pref.getString('userName');
      emailId = pref.getString('email');
      description = pref.getString('description');
    });
  }

  @override
  void initState() {
    getUsernameEmail();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).secondaryHeaderColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              child: Flexible(
            child: _buildBody(context),
          )),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        ProfilePhoto(user.uid),
        Container(
          child: Column(
            children: <Widget>[
              Text(
                userName != null ? userName : 'Name',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description != null ? description : 'Description',
                style: TextStyle(
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Divider(
          thickness: 10,
        ),
        StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('uid_photo_storage')
              .doc(user.uid)
              .collection('photos')
              .orderBy("time", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return LinearProgressIndicator();
            }
            return _buildList(context, snapshot.data.documents);
          },
        ),
      ],
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return Expanded(
      child: ListView(
        children:
            snapshot.map((data) => _buildListItem(context, data)).toList(),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          child: Card(
            elevation: 5,
            child: Column(
              children: <Widget>[
                Container(
                  color: Theme.of(context).secondaryHeaderColor,
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
                  trailing: FlatButton.icon(
                    onPressed: () {
                      FirebaseStorage.instance.refFromURL(record.url).delete();
                      FirebaseFirestore.instance
                          .collection('storage')
                          .where('url', isEqualTo: record.url)
                          .get()
                          .then((data) {
                        data.docs.first.reference.delete();
                      });
                      FirebaseFirestore.instance
                          .collection('uid_photo_storage')
                          .doc(user.uid)
                          .collection('photos')
                          .where('url', isEqualTo: record.url)
                          .get()
                          .then((data) {
                        data.docs.first.reference.delete();
                      });
                    },
                    icon: Icon(
                      Icons.delete,
                      color: Theme.of(context).errorColor,
                    ),
                    label: Text(
                      'Delete',
                      style: TextStyle(
                        color: Theme.of(context).errorColor,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class Record {
  final String userName;
  final String url;
  final String currentTime;
  final String time;
  final String userId;

  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['userName'] != null),
        assert(map['url'] != null),
        assert(map['currentTime'] != null),
        assert(map['time'] != null),
        assert(map['userId'] != null),
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
