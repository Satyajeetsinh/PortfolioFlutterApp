import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './home_screen.dart';
import './profile_screen.dart';
import '../widgets/main_drawer.dart';
import './add_photos.dart';
import './search_screen.dart';

class TabsScreen extends StatefulWidget {
  static const routeName = '/tabs-screen';
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  List<Map<String, Object>> _pages;
  int _selectedPageIndex = 0;

  setUsernameEmail(String username, String email, String description) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    preferences.setString('userName', username);
    preferences.setString('email', email);
    preferences.setString('description', description);
  }

  @override
  void initState() {
    _pages = [
      {
        'page': HomeScreen(),
        'title': 'Home',
      },
      {
        'page': AddPhotos(),
        'title': 'Add Photo',
      },
      {
        'page': ProfileScreen(),
        'title': 'Profile',
      },
    ];
    super.initState();
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;
    final User user = auth.currentUser;

    Future<void> userName() async {
      return await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get()
          .then((value) => value.data()['username'].toString());
    }

    Future<void> userEmail() async {
      return await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get()
          .then((value) => value.data()['email'].toString());
    }

    Future<void> userDes() async {
      return await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get()
          .then((value) => value.data()['description'].toString());
    }

    return FutureBuilder(
      future: Future.wait([userName(), userEmail(), userDes()]),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var firstData = snapshot.data[0].toString();
          var secondData = snapshot.data[1].toString();
          var thirdData = snapshot.data[2].toString();
          setUsernameEmail(firstData, secondData, thirdData);
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(_pages[_selectedPageIndex]['title']),
            actions: [
              Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      Navigator.of(context).pushNamed(SearchScreen.routeName);
                    },
                  ),
                ],
              )
            ],
          ),
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          drawer: MainDrawer(),
          body: _pages[_selectedPageIndex]['page'],
          bottomNavigationBar: BottomNavigationBar(
            onTap: _selectPage,
            backgroundColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.white,
            selectedItemColor: Theme.of(context).accentColor,
            currentIndex: _selectedPageIndex,
            // type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                backgroundColor: Theme.of(context).primaryColor,
                icon: const Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                backgroundColor: Theme.of(context).primaryColor,
                icon: const Icon(Icons.camera_alt),
                label: 'Add Photo',
              ),
              BottomNavigationBarItem(
                backgroundColor: Theme.of(context).primaryColor,
                icon: const Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
