import 'package:PhotographyPortfolio/main.dart';
import 'package:PhotographyPortfolio/screens/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings-screen';
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  String _emailId = '';
  String _password = '';
  String _oldPassword = '';

  getUsernameEmail() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    setState(() {
      _emailId = pref.getString('email');
    });
  }

  @override
  void initState() {
    getUsernameEmail();
    super.initState();
  }

  void _trySubmit() async {
    var isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();
    final auth = FirebaseAuth.instance;
    final User user = auth.currentUser;

    if (isValid) {
      _formKey.currentState.save();

      UserCredential authResult = await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: _emailId, password: _oldPassword),
      );
      await authResult.user.updatePassword(_password).then((_) {
        Fluttertoast.showToast(
          msg: 'Password changed',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16,
        );
        Navigator.of(context).pop();
      }).catchError((error) {
        Fluttertoast.showToast(
          msg: error.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16,
        );
      });
    }
  }

  void _tryDelete() async {
    var isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();
    final auth = FirebaseAuth.instance;
    final User user = auth.currentUser;

    if (isValid) {
      _formKey.currentState.save();

      UserCredential authResult = await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: _emailId, password: _oldPassword),
      );
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get()
          .then((data) {
        data.reference.delete();
      }).catchError((error) {});

      await FirebaseFirestore.instance
          .collection('storage')
          .where('userId', isEqualTo: user.uid)
          .get()
          .then((data) {
        data.docs.first.reference.delete();
      }).catchError((error) {});

      await FirebaseFirestore.instance
          .collection('uid_photo_storage')
          .doc(user.uid)
          .collection('photos')
          .where('userId', isEqualTo: user.uid)
          .get()
          .then((data) {
        data.docs.first.reference.delete();
      }).catchError((error) {});

      await authResult.user.delete().then((_) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) => MyApp()));
      }).catchError((error) {
        Fluttertoast.showToast(
          msg: error.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //update your password
    showAlertDialog(BuildContext context) {
      // set up the buttons
      Widget cancelButton = FlatButton(
        child: Text("Cancel",
            style: TextStyle(color: Theme.of(context).accentColor)),
        onPressed: () {
          Navigator.of(context).pop();
        },
      );
      Widget continueButton = FlatButton(
          child: Text(
            "Update",
            style: TextStyle(color: Theme.of(context).accentColor),
          ),
          onPressed: () {
            _trySubmit();
          });

      // set up the AlertDialog
      AlertDialog alert = AlertDialog(
        title: Text("Update your password"),
        content: Container(
          height: 150,
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  key: ValueKey('oldpassword'),
                  obscureText: true,
                  validator: (value) {
                    if (value.isEmpty || value.length < 7) {
                      return 'password must be at least 7 characters long';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Old Password',
                  ),
                  onSaved: (value) {
                    _oldPassword = value;
                  },
                ),
                TextFormField(
                  key: ValueKey('password'),
                  obscureText: true,
                  validator: (value) {
                    if (value.isEmpty || value.length < 7) {
                      return 'password must be at least 7 characters long';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'New Password',
                  ),
                  onSaved: (value) {
                    _password = value;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          cancelButton,
          continueButton,
        ],
      );

      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }

    //delete your account
    showAlertDeleteDialog(BuildContext context) {
      // set up the buttons
      Widget cancelButton = FlatButton(
        child: Text("Cancel",
            style: TextStyle(color: Theme.of(context).accentColor)),
        onPressed: () {
          Navigator.of(context).pop();
        },
      );
      Widget continueButton = FlatButton(
          child: Text(
            "Delete",
            style: TextStyle(color: Theme.of(context).accentColor),
          ),
          onPressed: () {
            _tryDelete();
          });

      // set up the AlertDialog
      AlertDialog alert = AlertDialog(
        title: Text("Delete your account"),
        content: Container(
          height: 100,
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  key: ValueKey('oldpassword'),
                  obscureText: true,
                  validator: (value) {
                    if (value.isEmpty || value.length < 7) {
                      return 'password must be at least 7 characters long';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Enter your password',
                  ),
                  onSaved: (value) {
                    _oldPassword = value;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          cancelButton,
          continueButton,
        ],
      );

      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Container(
        padding: EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            RaisedButton(
              onPressed: () {
                showAlertDialog(context);
              },
              child: Text('Change your password'),
              color: Theme.of(context).accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              textColor: Colors.white,
            ),
            RaisedButton(
              onPressed: () {
                showAlertDeleteDialog(context);
              },
              child: Text('Delete your account'),
              color: Theme.of(context).accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
