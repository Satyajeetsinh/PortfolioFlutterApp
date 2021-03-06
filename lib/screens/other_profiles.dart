import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/profile_photo.dart';
import './contact_screen.dart';

class OtherProfileScreen extends StatefulWidget {
  static const routeName = '/other-profile-screen';

  @override
  _OtherProfileScreenState createState() => _OtherProfileScreenState();
}

class _OtherProfileScreenState extends State<OtherProfileScreen> {
  final User user = FirebaseAuth.instance.currentUser;
  String userName;

  getUsername() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    setState(() {
      userName = pref.getString('userName');
    });
  }

  @override
  void initState() {
    getUsername();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final routeArg =
        ModalRoute.of(context).settings.arguments as Map<String, String>;
    final id = routeArg['id'];
    final name = routeArg['name'];
    final removeChar = name.replaceAll(new RegExp(r'[^\w\s]+'), '');
    final date = routeArg['date'];

    Future<void> userDes() async {
      return await FirebaseFirestore.instance
          .collection('Users')
          .doc(id)
          .get()
          .then((value) => value.data()['description'].toString());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(removeChar),
      ),
      backgroundColor: Theme.of(context).secondaryHeaderColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: Flexible(
              child: _buildBody(
                context,
                id,
                removeChar,
                date,
                userDes(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, String id, String removeChar,
      String date, Future<void> userDes) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 20,
        ),
        ProfilePhoto(id),
        Container(
          child: FutureBuilder(
            future: userDes,
            builder: (ctx, futureSnapshot) => Column(
              children: <Widget>[
                Text(
                  removeChar != null ? removeChar : 'Name',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  futureSnapshot.hasData ? futureSnapshot.data : 'Description',
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
                if (user.uid != id)
                  RaisedButton(
                    onPressed: () {
                      showModalBottomSheet(
                          context: ctx,
                          builder: (_) {
                            return GestureDetector(
                              onTap: () {},
                              child: ContactScreen(
                                id: id,
                              ),
                              behavior: HitTestBehavior.opaque,
                            );
                          });
                    },
                    child: Text('Contact'),
                    color: Theme.of(context).accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    textColor: Colors.white,
                  ),
              ],
            ),
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
              .doc(id)
              .collection('photos')
              .orderBy("currentTime", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return LinearProgressIndicator();
            }
            return _buildList(context, snapshot.data.documents, id);
          },
        ),
      ],
    );
  }

  Widget _buildList(
      BuildContext context, List<DocumentSnapshot> snapshot, String id) {
    return Expanded(
      child: ListView(
        children:
            snapshot.map((data) => _buildListItem(context, data, id)).toList(),
      ),
    );
  }

  Widget _buildListItem(
      BuildContext context, DocumentSnapshot data, String id) {
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
                  trailing: userName == 'admin'
                      ? FlatButton.icon(
                          onPressed: () {
                            FirebaseStorage.instance
                                .refFromURL(record.url)
                                .delete();
                            FirebaseFirestore.instance
                                .collection('storage')
                                .where('url', isEqualTo: record.url)
                                .get()
                                .then((data) {
                              data.docs.first.reference.delete();
                            });
                            FirebaseFirestore.instance
                                .collection('uid_photo_storage')
                                .doc(id)
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
                        )
                      : Text(''),
                ),
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
  final String userId;

  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['userName'] != null),
        assert(map['url'] != null),
        assert(map['currentTime'] != null),
        assert(map['userId'] != null),
        userName = map['userName'],
        url = map['url'],
        userId = map['userId'],
        currentTime = map['currentTime'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data(), reference: snapshot.reference);

  @override
  String toString() => 'Record<$userName:$url:$currentTime:$userId>';
}
