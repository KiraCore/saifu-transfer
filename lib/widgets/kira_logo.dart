import 'package:flutter/material.dart';

class KiraLogo extends StatelessWidget {
  const KiraLogo({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            "/kira_blue.png",
            fit: BoxFit.fill,
            height: 50,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            // ignore: prefer_const_constructors
            Text(
              "KIRA",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            // ignore: prefer_const_constructors
            Text(
              "Transfer",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            )
          ],
        )
      ],
    );
  }
}
