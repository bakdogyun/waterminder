import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moressang/provider.dart';
import 'package:moressang/screen/dataMain.dart';
import 'package:moressang/screen/homeMain.dart';
import 'package:moressang/screen/insightMain.dart';
import 'package:moressang/screen/login.dart';
import 'package:moressang/screen/settingMain.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'api/userData.dart';
import 'provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => UserState())],
      child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'moressang tracker',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: Base(),
    );
  }
}

class Base extends StatefulWidget {
  Base({super.key});

  @override
  State<Base> createState() => _BaseState();
}

class _BaseState extends State<Base> {
  int currentIndex = 0;
  final firestore = FirebaseFirestore.instance;
  bool isUser = false;

  /*
  void checkSignIn() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
      } else {}
    });
  }
  */

  void handleNav(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    context.read<UserState>().setLogIn();
    // TODO: implement initState
  }

  final List<Widget> nowMenu = [
    HomeMain(),
    DataMain(),
    InsightMain(),
    SettingMain()
  ];

  @override
  Widget build(BuildContext context) {
    isUser = context.watch<UserState>().isLoged;
    print(isUser);
    return isUser
        ? Scaffold(
            body: nowMenu[currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              selectedItemColor: Colors.blueAccent,
              selectedLabelStyle:
                  TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              onTap: handleNav,
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.file_copy_outlined), label: "Record"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.insights), label: "Insight"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: "Setting"),
              ],
              currentIndex: currentIndex,
              unselectedItemColor: Colors.blueGrey,
              type: BottomNavigationBarType.fixed,
            ),
          )
        : Login();
  }
}
