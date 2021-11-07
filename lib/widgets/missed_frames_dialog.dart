import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:saifu_air/utils/webcam/qr_code_scanner_web.dart';

class MissedFrames extends StatefulWidget {
  @override
  _MissedFramesState createState() => _MissedFramesState();
}

class _MissedFramesState extends State<MissedFrames> {
  int max = 0;
  double percentage = 0;
  List<String> qrData = [];
  bool scan = true;
  BuildContext dialogContext;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300, maxHeight: 250),
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
                        max = decoded['max'];
                        qrData.add(scanData);
                        var datasize = int.parse(qrData.toSet().length.toString());
                        percentage = (datasize / max) * 100;
                        print(percentage);
                      });
                    }
                  }
                },
              ),
            ),
          ),
          CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.black),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${percentage.toStringAsFixed(0)}" + "%",
                textAlign: TextAlign.center,
              ),
              SizedBox(
                width: 20,
              ),
              Text(
                qrData.toSet().length.toString() + "/" + "$max",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
