// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:saifu_qr/saifu_qr.dart';

// ignore: must_be_immutable
class ReceiveRequestDialog extends StatefulWidget {
  List stdMsgData = [];
  ReceiveRequestDialog(this.stdMsgData, {Key key}) : super(key: key);
  @override
  State<ReceiveRequestDialog> createState() => _ReceiveRequestDialogState();
}

class _ReceiveRequestDialogState extends State<ReceiveRequestDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 50,
      shape: const RoundedRectangleBorder(side: BorderSide(color: Colors.white, width: 5), borderRadius: BorderRadius.all(Radius.circular(8.0))),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  style: ButtonStyle(
                    overlayColor: MaterialStateColor.resolveWith((states) => Colors.white),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: Colors.black,
                  ),
                  label: Text(
                    "",
                    style: TextStyle(color: Colors.black),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                )),
                padding: const EdgeInsets.all(5.0),
                child: SaifuQR(
                  itemHeight: 350,
                  itemWidth: 350,
                  data: widget.stdMsgData,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 250,
                  child: ElevatedButton(
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text("Close", style: TextStyle(color: Colors.black)),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.grey[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
