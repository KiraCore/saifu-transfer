import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
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
  List<String> webcamData = [];

  bool firstScan = true;

  int originalMax = 0;

  int maxFrames = 0;

  bool recievedData = false;

  double percentage = 0;

  List<String> scannedData;
  String filename;
  String filetype;
  Uint8List fileData;

  void arrangeFrames() async {
    String data = "";
    var dataset = [];
    for (var i = 0; i < scannedData.length; i++) {
      var decodeJson = json.decode(scannedData[i]);
      dataset.add(decodeJson);
    }

    dataset.sort((m1, m2) {
      return m1[3].compareTo(m2[3]);
    });
    //var checksum;
    for (var i = 0; i < dataset.length; i++) {
      var dataValue = "";

      if (i == 0) {
        setState(() {
          filename = dataset[i][0];
          filetype = dataset[i][1];
          dataValue = dataset[i][4];
          //checksum = dataset[i]['checksum'];
          data = data + dataValue;
        });
      } else if (i != 0) {
        dataValue = dataset[i][4];
        data = data + dataValue;
      }
    }
    //var emoji = await EmojiCheckSum.convertToEmoji(checksum);
    var decode = base64.decode(data);
    var gzipBytes = GZipDecoder().decodeBytes(decode);
    //final decodedCheckSum = sha256.convert(gzipBytes).toString();
    setState(() {
      fileData = gzipBytes;
      print(fileData);
      //checkSumEmoji = emoji;
      //checksum == decodedCheckSum ? validChecksum = true : validChecksum = false;
    });
  }

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
                          borderRadius: BorderRadius.circular(12), // <-- Radius
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
