import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:saifu_air/utils/webcam/qr_code_scanner_web.dart';
import 'package:saifu_air/widgets/recieve_request_dialog.dart';

class QrCodeFileTransfer extends StatefulWidget {
  @override
  State<QrCodeFileTransfer> createState() => _QrCodeFileTransferState();
}

class _QrCodeFileTransferState extends State<QrCodeFileTransfer> {
  List<int> list = [];
  List<String> webcamData = [];
  bool secure = false;
  dynamic base64data = "";
  bool firstScan = true;

  int originalMax = 0;

  int maxFrames = 0;
  double percentage = 0;

  String filename;

  String filetype;

  Uint8List fileData;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 50,
      shape: RoundedRectangleBorder(side: BorderSide(color: Colors.white, width: 5), borderRadius: BorderRadius.all(Radius.circular(32.0))),
      content: SizedBox(
        width: 350,
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
                  onPressed: () => Navigator.pop(context, false),
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
            Center(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 350, maxHeight: 300),
                      child: QrCodeCameraWeb(
                        fit: BoxFit.contain,
                        qrCodeCallback: (scanData) async {
                          if (mounted && percentage != 100) {
                            webcamData.add(scanData);
                            final decoded = jsonDecode(scanData);
                            originalMax = decoded[2];
                            maxFrames = decoded[6];
                            secure = decoded[7] == 0 ? true : false;
                            setState(() {
                              percentage = (webcamData.toSet().length / originalMax) * 100;
                            });
                            if (percentage == 100) {
                              setState(() {
                                webcamData = webcamData.toSet().toList();
                                Navigator.pop(context, [webcamData, secure]);
                              });
                            }
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                  Text(
                    percentage.toStringAsFixed(2) + "%",
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          icon: Icon(
                            Icons.close_rounded,
                            color: Colors.red,
                          )),
                      SizedBox(
                        width: 200,
                        child: ElevatedButton.icon(
                          icon: Icon(
                            Icons.search_rounded,
                            color: Colors.green,
                          ),
                          label: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              "Request missed frames",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              list = List<int>.generate(originalMax, (i) => i + 1);
                              webcamData = webcamData.toSet().toList();
                            });

                            for (int i = 0; i < webcamData.length; i++) {
                              var data = jsonDecode(webcamData[i]);
                              list.remove(data[3]);
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
                            //Map<String, Object> framesData;
                            List<dynamic> framesData;
                            for (var i = 0; i < missedFrames.length; i++) {
                              var pageCount = i + 1;
                              framesData = [[], [], originalMax, pageCount, missedFrames[i], [], missedFrames.length];
                              //framesData = {"max": missedFrames.length, "data": missedFrames[i], "page": pageCount};
                              var jsonFrame = jsonEncode(framesData);
                              stdMsgData.add(jsonFrame);
                            }
                            // ignore: unnecessary_statements
                            stdMsgData.isNotEmpty == true ? showDialog(context: context, builder: (context) => RecieveRequestDialog(stdMsgData)) : null;
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12), // <-- Radius
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
