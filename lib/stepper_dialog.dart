import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:saifu_air/utils/webcam/qr_code_scanner_web.dart';
import 'package:saifu_air/widgets/droppedFile_widget.dart';
import 'package:saifu_air/modal/dropped_file.dart';
import 'package:saifu_air/utils/saifu_fast_qr.dart';
import 'package:slimy_card/slimy_card.dart';
import 'package:archive/archive.dart' show GZipEncoder;

// ignore: must_be_immutable
class StepperDialog extends StatefulWidget {
  DroppedFile file;
  DropzoneViewController controller;
  StepperDialog({Key key, this.file, this.controller}) : super(key: key);

  @override
  _StepperDialogState createState() => _StepperDialogState();
}

class _StepperDialogState extends State<StepperDialog> {
  List<String> stdMsgData = [];
  int stepper = 0;
  double percentage = 0;
  List<String> webcamQRData = [];
  Future<void> processData(var data, var splitValue) async {
    //print(data);
    RegExp frames = RegExp(".{1," + splitValue.toStringAsFixed(0) + "}");
    String str = base64.encode(data);
    Iterable<Match> matches = frames.allMatches(str);
    var list = matches.map((m) => m.group(0)).toList();
    stdMsgData = [];

    for (var i = 0; i < list.length; i++) {
      var pageCount = i + 1;
      Map<String, Object> framesData;
      if (i == 0) {
        framesData = {"name": widget.file.name, "type": widget.file.mime, "max": "${list.length}", "page": pageCount, "data": list[i]};
      } else {
        framesData = {"max": "${list.length}", "page": pageCount, "data": list[i]};
      }

      var jsonFrame = jsonEncode(framesData);
      stdMsgData.add(jsonFrame);
    }
  }

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 16);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SlimyCard(
          color: Colors.grey[200],
          width: 400,
          topCardHeight: 150,
          bottomCardHeight: 100,
          borderRadius: 15,
          topCardWidget: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (stepper == 0) ...[
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(
                    Radius.circular(20.0),
                  )),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              enableFeedback: false,
                              primary: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                              elevation: 0,
                            ),
                            onPressed: () {},
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    DroppedFileWidget(
                                      file: widget.file,
                                      controller: widget.controller,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          widget.file.name,
                                          style: style.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          widget.file.mime,
                                          style: style,
                                        ),
                                        Text(
                                          widget.file.size,
                                          style: style,
                                        ),
                                      ],
                                    ),
                                    const Icon(Icons.arrow_forward_ios_rounded, size: 40, color: Colors.black),
                                  ],
                                ),
                              ],
                            )),
                      ],
                    ),
                  ),
                ),
              ],
              if (stepper == 1) ...[
                SaifuFastQR(
                  transitionDuration: 100,
                  itemHeight: 300,
                  itemWidth: 300,
                  data: stdMsgData,
                ),
              ],
              if (stepper == 2) ...[
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 200, maxHeight: 200),
                    child: QrCodeCameraWeb(
                      fit: BoxFit.contain,
                      qrCodeCallback: (scanData) async {
                        //print(scanData);

                        if (mounted && percentage != 100) {
                          final decoded = jsonDecode(scanData);
                          int max = int.parse(decoded['max']);

                          var datasize = int.parse(webcamQRData.toSet().length.toString());
                          setState(() {
                            percentage = (datasize / max) * 100;
                            webcamQRData.add(scanData);
                          });
                          if (percentage == 100) {}
                        }
                      },
                    ),
                  ),
                ),
                Text(
                  "${percentage.toStringAsFixed(0)}" "%",
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
          bottomCardWidget: null,
          slimeEnabled: true,
        ),
        TextButton(
            onPressed: () async {
              var data = await widget.controller.getFileData(widget.file.event);
              var gzipBytes = GZipEncoder().encode(data);
              //var compressedString = base64.encode(gzipBytes);
              processData(gzipBytes, 100);
              setState(() {
                stepper++;
              });
            },
            child: const Text("Next Dialog"))
      ],
    );
  }
}
