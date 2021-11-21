import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:saifu_air/utils/checksum_emojis.dart';
import 'package:saifu_air/utils/saifu_fast_qr.dart';
import 'package:saifu_air/utils/webcam/qr_code_scanner_web.dart';

class RecieveDialog extends StatefulWidget {
  @override
  _RecieveDialogState createState() => _RecieveDialogState();
}

class _RecieveDialogState extends State<RecieveDialog> {
  List<int> list = [];
  List<String> webcamData = [];
  double percentage = 0;
  bool firstScan = true;
  bool recievedData = false;
  int originalMax = 0;
  int maxFrames = 0;
  bool expandedTile = false;
  bool validChecksum = true;
  Uint8List fileData;
  var scannedData;
  var filename;
  var filetype;
  var checkSumEmoji;

  void arrangeFrames() async {
    String data = "";
    var dataset = [];
    for (var i = 0; i < scannedData.length; i++) {
      var decodeJson = json.decode(scannedData[i]);
      dataset.add(decodeJson);
    }

    dataset.sort((m1, m2) {
      return m1["page"].compareTo(m2["page"]);
    });
    var checksum;
    for (var i = 0; i < dataset.length; i++) {
      var dataValue = "";

      if (i == 0) {
        setState(() {
          filename = dataset[i]['name'];
          filetype = dataset[i]['type'];
          dataValue = dataset[i]['data'];
          checksum = dataset[i]['checksum'];
          data = data + dataValue;
        });
      } else if (i != 0) {
        dataValue = dataset[i]['data'];
        data = data + dataValue;
      }
    }
    var emoji = await EmojiCheckSum.convertToEmoji(checksum);
    var decode = base64.decode(data);
    var gzipBytes = GZipDecoder().decodeBytes(decode);
    final decodedCheckSum = sha256.convert(gzipBytes).toString();
    setState(() {
      fileData = gzipBytes;
      checkSumEmoji = emoji;
      checksum == decodedCheckSum ? validChecksum = true : validChecksum = false;
    });
  }

  Future<void> downloadFile() async {
    switch (filetype) {
      case "json":
        await FileSaver.instance.saveFile(filename, fileData, '.json', mimeType: MimeType.JSON);
        Navigator.of(context).pop();
        break;
      case "png":
        await FileSaver.instance.saveFile(filename, fileData, '.png', mimeType: MimeType.PNG);
        Navigator.of(context).pop();
        break;
      case "mp3":
        await FileSaver.instance.saveFile(filename, fileData, '.mp3', mimeType: MimeType.MP3);
        Navigator.of(context).pop();
        break;
      case "jpg":
        await FileSaver.instance.saveFile(filename, fileData, '.jpg', mimeType: MimeType.JPEG);
        Navigator.of(context).pop();
        break;
      case "gif":
        await FileSaver.instance.saveFile(filename, fileData, '.gif', mimeType: MimeType.GIF);
        Navigator.of(context).pop();
        break;
      case "txt":
        await FileSaver.instance.saveFile(filename, fileData, '.txt', mimeType: MimeType.TEXT);
        Navigator.of(context).pop();
        break;
      case "pdf":
        await FileSaver.instance.saveFile(filename, fileData, '.pdf', mimeType: MimeType.PDF);
        Navigator.of(context).pop();
        break;
      case "zip":
        await FileSaver.instance.saveFile(filename, fileData, '.zip', mimeType: MimeType.ZIP);
        Navigator.of(context).pop();
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 600,
          width: 400,
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
            child: Scaffold(
                backgroundColor: Colors.white,
                body: !recievedData
                    ? Container(
                        height: 650,
                        width: 400,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Scan QR-Code",
                              style: TextStyle(color: Colors.black, fontSize: 16),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 300, maxHeight: 250),
                                child: QrCodeCameraWeb(
                                  fit: BoxFit.contain,
                                  qrCodeCallback: (scanData) async {
                                    if (mounted && percentage != 100) {
                                      webcamData.add(scanData);
                                      final decoded = jsonDecode(scanData);

                                      if (firstScan == true) {
                                        originalMax = int.parse(decoded['max']);
                                        firstScan = false;
                                      }
                                      maxFrames = int.parse(decoded['max']);

                                      var datasize = int.parse(webcamData.toSet().length.toString());
                                      setState(() {
                                        percentage = (datasize / originalMax) * 100;
                                      });
                                      if (percentage == 100) {
                                        setState(() {
                                          recievedData = true;
                                          scannedData = webcamData.toSet().toList();
                                          arrangeFrames();
                                        });
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                            Text(
                              percentage.toStringAsFixed(2) + "%",
                              textAlign: TextAlign.center,
                            ),
                            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(primary: Colors.white),
                                  onPressed: () async {
                                    setState(() {
                                      list = List<int>.generate(originalMax, (i) => i + 1);
                                      webcamData = webcamData.toSet().toList();
                                    });

                                    for (int i = 0; i < webcamData.length; i++) {
                                      var data = jsonDecode(webcamData[i]);
                                      list.remove(data['page']);
                                    }
                                    List stdMsgData = [];
                                    List<List<int>> missedFrames = [];
                                    for (var i = 0; i < list.length; i++) {
                                      var data = list.skip(15 * i).take(15).toList();
                                      if (data.length == 0) {
                                        break;
                                      } else {
                                        missedFrames.add(data);
                                      }
                                    }

                                    Map<String, Object> framesData;
                                    for (var i = 0; i < missedFrames.length; i++) {
                                      var pageCount = i + 1;
                                      framesData = {"max": missedFrames.length, "data": missedFrames[i], "page": pageCount};
                                      var jsonFrame = jsonEncode(framesData);
                                      stdMsgData.add(jsonFrame);
                                    }
                                    stdMsgData.length != 0
                                        ? showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                                  content: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        decoration: BoxDecoration(
                                                            color: Colors.grey[100],
                                                            borderRadius: BorderRadius.all(
                                                              Radius.circular(10.0),
                                                            )),
                                                        padding: const EdgeInsets.all(5.0),
                                                        child: SaifuFastQR(
                                                          itemHeight: 400,
                                                          itemWidth: 400,
                                                          data: stdMsgData,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ))
                                        : null;
                                  },
                                  icon: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.document_scanner_rounded,
                                      color: Colors.black,
                                    ),
                                  ),
                                  label: Text(
                                    "Missed Frames?",
                                    style: TextStyle(color: Colors.black),
                                  ))
                            ]),
                          ],
                        ),
                      )
                    : Container(
                        height: 600,
                        width: 400,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Scan QR-Code",
                              style: TextStyle(color: Colors.black, fontSize: 16),
                            ),
                            Spacer(),
                            Center(
                              child: Container(
                                height: 500,
                                width: 500,
                                decoration: new BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Spacer(),
                                    Container(
                                      decoration: new BoxDecoration(color: Colors.black, shape: BoxShape.rectangle, borderRadius: BorderRadius.all(Radius.circular(30.0))),
                                      padding: const EdgeInsets.all(8.0),
                                      child: ExpansionTile(
                                        iconColor: Colors.white,
                                        collapsedIconColor: Colors.white,
                                        title: expandedTile
                                            ? Text(
                                                checkSumEmoji[0],
                                                style: TextStyle(fontSize: 20),
                                                textAlign: TextAlign.center,
                                              )
                                            : Text(
                                                checkSumEmoji[1],
                                                style: TextStyle(fontSize: 20),
                                                textAlign: TextAlign.center,
                                              ),
                                        onExpansionChanged: (bool expanded) {
                                          setState(() {
                                            expandedTile = expanded;
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                      child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10.0),
                                            ),
                                            shape: BoxShape.rectangle,
                                          ),
                                          height: 300,
                                          width: 300,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              validChecksum
                                                  ? Text("DATA IS MATCHED", style: TextStyle(color: Colors.green, fontSize: 20))
                                                  : Text(
                                                      "DATA IS MANIPULATED",
                                                      style: TextStyle(color: Colors.red, fontSize: 20),
                                                    ),
                                              SizedBox(
                                                height: 30,
                                              ),
                                              Text(
                                                "Name: " + filename + "\n" + "Type: " + filetype,
                                              ),
                                            ],
                                          )),
                                    ),
                                    Spacer()
                                  ],
                                ),
                              ),
                            ),
                            Spacer(),
                            Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border: new Border.all(
                                      color: Colors.grey[400],
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      children: [
                                        Spacer(),
                                        TextButton(
                                          style: ButtonStyle(
                                            overlayColor: MaterialStateProperty.all(Colors.transparent),
                                          ),
                                          onPressed: () {
                                            downloadFile();
                                          },
                                          child: Text(
                                            "Download the file",
                                            style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        Spacer()
                                      ],
                                    ),
                                  ),
                                ))
                          ],
                        ),
                      )),
          ),
        ),
      ],
    );
  }
}
