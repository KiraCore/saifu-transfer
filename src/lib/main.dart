import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saifu_air/screens/navigation_bottom.dart';
import 'package:saifu_air/screens/navigation_top.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(textTheme: GoogleFonts.arimoTextTheme(Theme.of(context).textTheme)),
      debugShowCheckedModeBanner: false,
      title: 'Kira Transfer',
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                NavigationTop(),
                NavigationBottom(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
