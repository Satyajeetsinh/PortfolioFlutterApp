import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        source: ImageSource.camera, imageQuality: 85);
    setState(() {
      _storedImage = File(imageFile.path);
    });
  }

  Future<void> _takeGalleryPicture() async {
    final imagePickerGallery = ImagePicker();
    final imageFileGallery = await imagePickerGallery.getImage(
        source: ImageSource.gallery, imageQuality: 85);
    setState(() {
      _storedImage = File(imageFileGallery.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    void _uploadImage() async {
      try {
        final User user = auth.currentUser;
        final time = DateTime.now().toString();
        final uploadTime = DateFormat.yMMMd().format(DateTime.now()).toString();
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
          'location': userData,
          'currentTime': uploadTime,
          'userId': user.uid,
        });
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload Successful'),
          ),
        );
      } catch (err) {
        var message = 'Error, please try again';
        if (err.message != null) {
          message = err.message;
        }
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context).errorColor,
          ),
        );
      }
    }

    return Scaffold(
      body: Container(
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
                _uploadImage();
              },
              child: const Text('Upload'),
              color: Theme.of(context).accentColor,
            ),
          ],
        ),
      ),
    );
  }
}
