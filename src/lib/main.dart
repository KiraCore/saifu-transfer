import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saifu_air/screens/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Saifu Transfer',
      home: MainScreen(),
    );
  }
}
