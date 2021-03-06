import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePhoto extends StatelessWidget {
  final String id;

  ProfilePhoto(this.id);

  final User user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('uid_photo_storage')
          .doc(id)
          .collection('profile_photo')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        }
        return SizedBox(
          height: 200,
          child: ListView(
            children: snapshot.data.docs.map((DocumentSnapshot document) {
              final url = document.data()['profilePhotoUrl'];
              return url == null
                  ? Center(
                      child: Icon(
                        Icons.person,
                        size: 180,
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.all(10),
                      height: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          onError: (exception, stackTrace) => Text('Try again'),
                          fit: BoxFit.scaleDown,
                          image: NetworkImage(url),
                        ),
                      ),
                    );
            }).toList(),
          ),
        );
      },
    );
  }
}
