import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddPhotos extends StatefulWidget {
  @override
  _AddPhotosState createState() => _AddPhotosState();
}

class _AddPhotosState extends State<AddPhotos> {
  File _storedImage;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> _takeCameraPicture() async {
    final imagePicker = ImagePicker();
    final imageFile = await imagePicker.getImage(
      source: ImageSource.camera,
      imageQuality: 30,
    );
    setState(() {
      _storedImage = File(imageFile.path);
    });
  }

  Future<void> _takeGalleryPicture() async {
    final imagePickerGallery = ImagePicker();
    final imageFileGallery = await imagePickerGallery.getImage(
      source: ImageSource.gallery,
      imageQuality: 30,
    );
    setState(() {
      _storedImage = File(imageFileGallery.path);
    });
  }

  bool _loadingBar = false;
  @override
  Widget build(BuildContext context) {
    void _uploadImage() async {
      try {
        final User user = auth.currentUser;
        final time = DateTime.now().toString();
        final uploadTime =
            DateFormat.yMMMd().add_jm().format(DateTime.now()).toString();
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_photos')
            .child(user.uid + ':' + time + '.jpg');
        await ref.putFile(_storedImage);

        final downloadUrl = await ref.getDownloadURL();
        final userData = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get()
            .then((value) => value.data()['username'].toString());
        await FirebaseFirestore.instance.collection('storage').doc().set({
          'url': downloadUrl,
          'userName': userData,
          'currentTime': uploadTime,
          'userId': user.uid,
          'time': time,
        });
        await FirebaseFirestore.instance
            .collection('uid_photo_storage')
            .doc(user.uid)
            .collection('photos')
            .doc()
            .set({
          'url': downloadUrl,
          'userName': userData,
          'currentTime': uploadTime,
          'userId': user.uid,
          'time': time,
        });
        setState(() {
          _loadingBar = false;
        });
        Fluttertoast.showToast(
          msg: 'Photo uploaded',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          timeInSecForIosWeb: 1,
          fontSize: 16,
        );
      } catch (err) {
        var message = 'Error, please try again';
        if (err.message != null) {
          message = err.message;
        }
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          timeInSecForIosWeb: 1,
          fontSize: 16,
        );
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).secondaryHeaderColor,
      body: _loadingBar == false
          ? Container(
              padding: EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.grey),
                      ),
                      child: _storedImage != null
                          ? Image.file(
                              _storedImage,
                              fit: BoxFit.scaleDown,
                              width: double.infinity,
                              height: double.infinity,
                            )
                          : Text(
                              'No image selected',
                              style: TextStyle(
                                color: Theme.of(context).textSelectionColor,
                              ),
                            ),
                      alignment: Alignment.center,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      FlatButton.icon(
                        onPressed: _takeCameraPicture,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                        //color: Theme.of(context).accentColor,
                      ),
                      FlatButton.icon(
                        onPressed: _takeGalleryPicture,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                        //color: Theme.of(context).accentColor,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  RaisedButton(
                    onPressed: () {
                      setState(() {
                        _loadingBar = true;
                      });
                      _uploadImage();
                    },
                    child: const Text('Upload'),
                    color: Theme.of(context).accentColor,
                  ),
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
