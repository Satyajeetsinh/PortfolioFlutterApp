import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditProfileScreen extends StatefulWidget {
  static const routeName = '/edit-profile-screen';
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String _userName = '';
  String _userPassword = '';
  String _userDescription = '';
  String _userPhone = '';
  File _storedImages;

  Future<void> _takeGalleryPicture() async {
    final imagePickerGallery = ImagePicker();
    final imageFileGallery = await imagePickerGallery.getImage(
        source: ImageSource.gallery, imageQuality: 85);
    setState(() {
      _storedImages = File(imageFileGallery.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;
    final routeArg =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    final id = routeArg['id'];
    final name = routeArg['name'];
    bool _loadingBar = false;

    void _trySubmit() async {
      var isValid = _formKey.currentState.validate();
      FocusScope.of(context).unfocus();

      if (isValid) {
        _formKey.currentState.save();

        try {
          final User user = auth.currentUser;

          final ref = FirebaseStorage.instance
              .ref()
              .child('profile_pictures')
              .child(user.uid + '.jpg');
          await ref.putFile(_storedImages);
          final downloadUrl = await ref.getDownloadURL();

          await FirebaseFirestore.instance
              .collection('uid_photo_storage')
              .doc(user.uid)
              .collection('profile_photo')
              .doc(user.uid)
              .set({
            'profilePhotoUrl': downloadUrl,
          });
          setState(() {
            _loadingBar = false;
          });
        } catch (err) {}

        await FirebaseFirestore.instance.collection('Users').doc(id).update(
          {
            'username': _userName,
            'password': _userPassword,
            'description': _userDescription,
            'phone': _userPhone,
          },
        );

        Fluttertoast.showToast(
          msg: 'Profile Updated',
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
        title: Text('Edit Profile'),
      ),
      body: _loadingBar == false
          ? Container(
              padding: EdgeInsets.all(15),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    CircleAvatar(
                      maxRadius: 100,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: _storedImages != null
                          ? Image.file(
                              _storedImages,
                              fit: BoxFit.fill,
                              width: double.infinity,
                              height: double.infinity,
                            )
                          : Icon(
                              Icons.photo,
                              color: Colors.white,
                              size: 100,
                            ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    FlatButton(
                      onPressed: () {
                        setState(() {
                          _loadingBar = true;
                        });
                        _takeGalleryPicture();
                      },
                      child: Text('Add Photo'),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            initialValue: name,
                            key: ValueKey('username'),
                            validator: (value) {
                              if (value.isEmpty ||
                                  value.length < 4 ||
                                  value.contains('admin')) {
                                return 'short username or keyword not allowed';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Username',
                            ),
                            onSaved: (value) {
                              _userName = value;
                            },
                          ),
                          TextFormField(
                            key: ValueKey('description'),
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            validator: (value) {
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Description',
                            ),
                            onSaved: (value) {
                              _userDescription = value;
                            },
                          ),
                          TextFormField(
                            key: ValueKey('phone'),
                            validator: (value) {
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Phone number',
                            ),
                            onSaved: (value) {
                              _userPhone = value;
                            },
                          ),
                          TextFormField(
                            key: ValueKey('password'),
                            validator: (value) {
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'New Password',
                            ),
                            obscureText: true,
                            onSaved: (value) {
                              _userPassword = value;
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          RaisedButton(
                            onPressed: () {
                              _trySubmit();
                            },
                            child: Text('Save'),
                            color: Theme.of(context).accentColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            textColor: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
