import 'package:flutter/material.dart';
import 'package:saifu_air/widgets/kira_logo.dart';
import 'package:saifu_air/user_interaction.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const KiraLogo(),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "About",
                          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20, color: Colors.grey[400]),
                        ),
                        Text(
                          "How it works",
                          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20, color: Colors.grey[400]),
                        ),
                        Text(
                          "Features",
                          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20, color: Colors.grey[400]),
                        )
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 500,
                decoration: const BoxDecoration(
                    color: Color.fromRGBO(37, 65, 178, 1),
                    borderRadius: BorderRadius.all(
                      Radius.circular(20.0),
                    )),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Transfer files using Qr-codes",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w300, fontSize: 30, color: Colors.white),
                    ),
                    Text(
                      "the convenient way to send files, in a fast and secure manner",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w100, fontSize: 15, color: Colors.blueGrey[100]),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    UserInteraction()
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
