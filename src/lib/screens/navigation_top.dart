import 'package:flutter/material.dart';

class NavigationTop extends StatelessWidget {
  const NavigationTop({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(0.0),
      child: Column(
        children: [
          Text(
            "KIRA TRANSFER",
            style: TextStyle(
              color: Colors.black,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          Visibility(
            visible: false,
            child: Text(
              "Send files, in a fast and secure manner. Offline with security and quality.",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w100, fontSize: 18, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
