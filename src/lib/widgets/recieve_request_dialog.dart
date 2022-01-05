import 'package:flutter/material.dart';
import 'package:saifu_air/utils/saifu_fast_qr.dart';

// ignore: must_be_immutable
class RecieveRequestDialog extends StatefulWidget {
  List stdMsgData = [];
  RecieveRequestDialog(this.stdMsgData);
  @override
  State<RecieveRequestDialog> createState() => _RecieveRequestDialogState();
}

class _RecieveRequestDialogState extends State<RecieveRequestDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 50,
      shape: RoundedRectangleBorder(side: BorderSide(color: Colors.white, width: 5), borderRadius: BorderRadius.all(Radius.circular(32.0))),
      content: SizedBox(
        width: 350,
        height: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TextButton.icon(
                  style: ButtonStyle(
                    overlayColor: MaterialStateColor.resolveWith((states) => Colors.white),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.navigate_before,
                    color: Colors.black,
                  ),
                  label: Text(
                    "Back",
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
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    )),
                padding: const EdgeInsets.all(5.0),
                child: SaifuFastQR(
                  itemHeight: 400,
                  itemWidth: 350,
                  data: widget.stdMsgData,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Visibility(
              visible: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        color: Colors.red,
                      )),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton.icon(
                      icon: Icon(
                        Icons.done_rounded,
                        color: Colors.green,
                      ),
                      label: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          "Confirm",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
