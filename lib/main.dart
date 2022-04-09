import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:saifu_air/widgets/recieve_button.dart';
import 'package:saifu_air/widgets/title_widget.dart';
import 'package:saifu_air/widgets/upload_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  DropzoneViewController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Container(
                color: Colors.white,
                child: const TitleWidget(),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Container(
              width: 500,
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 100,
                  ),
                ],
              ),
              child: const MenuNavigation(),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class MenuNavigation extends StatelessWidget {
  const MenuNavigation({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      // ignore: prefer_const_literals_to_create_immutables
      children: [
        const Expanded(
          child: UploadButton(),
        ),
        const SizedBox(
          width: 20,
        ),
        const Expanded(
          child: RecieveButton(),
        ),
      ],
    );
  }
}
