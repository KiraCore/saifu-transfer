// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:saifu_air/webcam/qr_code_scanner_web.dart';
import 'package:saifu_air/widgets/receive_request_dialog.dart';

class QrCodeFileTransfer extends StatefulWidget {
  const QrCodeFileTransfer({Key key}) : super(key: key);

  @override
  State<QrCodeFileTransfer> createState() => _QrCodeFileTransferState();
}

class _QrCodeFileTransferState extends State<QrCodeFileTransfer> {
  List<int> list = [];
  List<String> webcamData = [];
  bool secure = false;
  int originalMax = 0;
  int maxFrames = 0;
  double percentage = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 50,
      shape: const RoundedRectangleBorder(side: BorderSide(color: Colors.white, width: 5), borderRadius: BorderRadius.all(Radius.circular(8.0))),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  style: ButtonStyle(
                    overlayColor: MaterialStateColor.resolveWith((states) => Colors.white),
                  ),
                  onPressed: () => Navigator.pop(context, false),
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
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                  Text(
                    percentage.toStringAsFixed(2) + "%",
                    textAlign: TextAlign.center,
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
                            child: Text(
                              "Request missed frames",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          onPressed: () async {
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
                              if (data.isEmpty) {
                                break;
                              } else {
                                missedFrames.add(data);
                              }
                            }
                            List<dynamic> framesData;
                            for (var i = 0; i < missedFrames.length; i++) {
                              var pageCount = i + 1;
                              framesData = [[], [], originalMax, pageCount, missedFrames[i], [], missedFrames.length];
                              var jsonFrame = jsonEncode(framesData);
                              stdMsgData.add(jsonFrame);
                            }
                            // ignore: unnecessary_statements
                            stdMsgData.isNotEmpty == true ? showDialog(context: context, builder: (context) => ReceiveRequestDialog(stdMsgData)) : null;
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
            )
          ],
        ),
      ),
    );
  }
}
