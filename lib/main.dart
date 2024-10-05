import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:taskist/ui/page_done.dart';
import 'package:taskist/ui/page_settings.dart';
import 'package:taskist/ui/page_task.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  _currentUser = await _signInAnonymously();

  runApp(new TaskistApp());
}
final FirebaseAuth _auth = FirebaseAuth.instance;

late User _currentUser;

Future<User> _signInAnonymously() async {
  final userCredential = await _auth.signInAnonymously();

  return userCredential.user!;
}

class HomePage extends StatefulWidget {
  final User user;

  HomePage({required Key key, required this.user}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class TaskistApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Taskist",
      home: HomePage(
        user: _currentUser, key: Key("HomePage"),
      ),
      theme: new ThemeData(primarySwatch: Colors.blue),
    );
  }
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 1;

  final List<Widget> _children = [
    DonePage(
      user: _currentUser, key: Key("DonePage"),
    ),
    TaskPage(
      user: _currentUser, key: Key("TaskPage"),
    ),
    SettingsPage(
      user: _currentUser, key: Key("SettingsPage"),
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        fixedColor: Colors.deepPurple,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: new Icon(FontAwesomeIcons.calendarCheck),
              label:""),
          BottomNavigationBarItem(
              icon: new Icon(FontAwesomeIcons.calendar), label: ""),
          BottomNavigationBarItem(
              icon: new Icon(FontAwesomeIcons.sliders), label: "")
        ],
      ),
      body: _children[_currentIndex],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}