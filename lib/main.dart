import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './screens/home_screen.dart';
import './screens/contact_screen.dart';
import './screens/login_screen.dart';
import './screens/message_screen.dart';
import './screens/profile_screen.dart';
import './widgets/messages.dart';
import './screens/tabs_screen.dart';
import './screens/other_profiles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PhotographyPortfolio',
      theme: ThemeData(
        primaryColor: Colors.blue,
        accentColor: Colors.amber,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, userSnapshot) {
          if (userSnapshot.hasData) {
            return TabsScreen();
          }
          return LoginScreen();
        },
      ),
      routes: {
        TabsScreen.routeName: (ctx) => TabsScreen(),
        HomeScreen.routeName: (ctx) => HomeScreen(),
        ContactScreen.routeName: (ctx) => ContactScreen(),
        LoginScreen.routeName: (ctx) => LoginScreen(),
        MessagesScreen.routeName: (ctx) => MessagesScreen(),
        ProfileScreen.routeName: (ctx) => ProfileScreen(),
        Messages.routeName: (ctx) => Messages(),
        OtherProfileScreen.routeName: (ctx) => OtherProfileScreen(),
      },
    );
  }
}
