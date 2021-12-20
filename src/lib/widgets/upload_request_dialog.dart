import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:saifu_air/utils/webcam/qr_code_scanner_web.dart';

class UploadRequestDialog extends StatefulWidget {
  @override
  State<UploadRequestDialog> createState() => _UploadRequestDialogState();
}

class _UploadRequestDialogState extends State<UploadRequestDialog> {
  int max = 0;
  double percentage = 0;
  List<String> qrData = [];
  bool scan = true;

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
                          if (mounted) {
                            if (percentage == 100 && scan == true) {
                              scan = false;
                              qrData = qrData.toSet().toList();
                              Navigator.pop(context, qrData);
                            } else if (percentage < 100) {
                              final decoded = jsonDecode(scanData);

                              setState(() {
                                max = decoded[6];
                                qrData.add(scanData);
                                var datasize = int.parse(qrData.toSet().length.toString());
                                percentage = (datasize / max) * 100;
                              });
                            }
                          }
                        },
                      ),
                    ),
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
                        height: 50,
                        width: 200,
                        child: ElevatedButton(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${percentage.toStringAsFixed(2)}" + "%",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                qrData.toSet().length.toString() + "/" + "$max",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
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
