import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TitleWidget extends StatelessWidget {
  const TitleWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "SAIFU TRANSFER",
          style: TextStyle(fontSize: 24, color: Colors.black),
        ),
        InkWell(
          hoverColor: Colors.white,
          onTap: () {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    content: Builder(builder: (context) {
                      return SizedBox(
                          width: 300,
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Text("What is SAIFU?"),
                            Divider(),
                            SizedBox(
                              height: 10,
                            ),
                            Text("An offline secure app that makes security and cryptography simple without requiring user to purchase any expensive, third party devices."),
                            Divider(),
                            SizedBox(
                              height: 20,
                            ),
                            Text("Don't have SAIFU? Download at: "),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    height: 75,
                                    width: 200,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage('/google_store.png'),
                                      ),
                                    ),
                                    child: TextButton(
                                        onPressed: () async {
                                          if (await canLaunch("https://play.google.com/store/apps/details?id=com.saifu.app")) {
                                            await launch("https://play.google.com/store/apps/details?id=com.saifu.app");
                                          } else {
                                            throw 'Could not launch null';
                                          }
                                        },
                                        style: ButtonStyle(
                                          overlayColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
                                        ),
                                        child: null),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    height: 75,
                                    width: 200,
                                    padding: EdgeInsets.all(0),
                                    decoration: BoxDecoration(
                                      image: DecorationImage(image: AssetImage('/app_store.png'), fit: BoxFit.contain),
                                    ),
                                    child: TextButton(
                                        onPressed: () async {
                                          if (await canLaunch("https://play.google.com/store")) {
                                            await launch("https://play.google.com/store");
                                          } else {
                                            throw 'Could not launch null';
                                          }
                                        },
                                        style: ButtonStyle(
                                          overlayColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
                                        ),
                                        child: null),
                                  ),
                                ],
                              ),
                            ),
                          ]));
                    })));
          },
          child: Icon(Icons.help_outline, size: 16, color: Colors.blue),
        ),
      ],
    );
  }
}
