// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:saifu_air/webcam/qr_code_scanner_web.dart';

class UploadRequestDialog extends StatefulWidget {
  const UploadRequestDialog({Key key}) : super(key: key);

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
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.black,
                    ),
                    label: const Text(
                      "",
                      style: TextStyle(color: Colors.black),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
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
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    percentage.toStringAsFixed(2) + "%",
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
            ],
          ),
        ));
  }
}
