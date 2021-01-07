import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddPhotos extends StatefulWidget {
  @override
  _AddPhotosState createState() => _AddPhotosState();
}

class _AddPhotosState extends State<AddPhotos> {
  File _storedImage;

  Future<void> _takeCameraPicture() async {
    final imagePicker = ImagePicker();
    final imageFile = await imagePicker.getImage(source: ImageSource.camera);
    setState(() {
      _storedImage = File(imageFile.path);
    });
  }

  Future<void> _takeGalleryPicture() async {
    final imagePickerGallery = ImagePicker();
    final imageFileGallery =
        await imagePickerGallery.getImage(source: ImageSource.gallery);
    setState(() {
      _storedImage = File(imageFileGallery.path);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                        fit: BoxFit.cover,
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
              onPressed: () {},
              child: const Text('Upload'),
              color: Theme.of(context).accentColor,
            ),
          ],
        ),
      ),
    );
  }
}
