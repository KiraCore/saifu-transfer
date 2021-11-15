import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:saifu_air/utils/saifu_fast_qr.dart';
import 'package:saifu_air/utils/webcam/qr_code_scanner_web.dart';
import 'package:slimy_card/slimy_card.dart';

class RecieveDialog extends StatefulWidget {
  @override
  _RecieveDialogState createState() => _RecieveDialogState();
}

class _RecieveDialogState extends State<RecieveDialog> {
  List<int> list = [];
  List<String> webcamQRData = [];
  double percentage = 0;
  bool firstScan = true;
  int originalMax = 0;
  int maxFrames = 0;
  var downloadeddata;
  var filename;
  var filetype;
  Uint8List filedata;

  void arrangeFrames() async {
    String data = "";
    var dataset = [];
    for (var i = 0; i < downloadeddata.length; i++) {
      var decodeJson = json.decode(downloadeddata[i]);
      dataset.add(decodeJson);
    }

    dataset.sort((m1, m2) {
      return m1["page"].compareTo(m2["page"]);
    });

    for (var i = 0; i < dataset.length; i++) {
      var dataValue = "";
      if (i == 0) {
        setState(() {
          filename = dataset[i]['name'];
          filetype = dataset[i]['type'];
          dataValue = dataset[i]['data'];
          data = data + dataValue;
        });
      } else if (i != 0) {
        dataValue = dataset[i]['data'];
        data = data + dataValue;
      }
    }
    var decode = base64.decode(data);

    var gzipBytes = GZipDecoder().decodeBytes(decode);

    setState(() {
      filedata = gzipBytes;
    });
    switch (filetype) {
      case "json":
        await FileSaver.instance.saveFile(filename, filedata, '.json', mimeType: MimeType.JSON);
        Navigator.of(context).pop();
        break;
      case "png":
        await FileSaver.instance.saveFile(filename, filedata, '.png', mimeType: MimeType.PNG);
        Navigator.of(context).pop();
        break;
      case "mp3":
        await FileSaver.instance.saveFile(filename, filedata, '.mp3', mimeType: MimeType.MP3);
        Navigator.of(context).pop();
        break;
      case "jpg":
        await FileSaver.instance.saveFile(filename, filedata, '.jpg', mimeType: MimeType.JPEG);
        Navigator.of(context).pop();
        break;
      case "gif":
        await FileSaver.instance.saveFile(filename, filedata, '.gif', mimeType: MimeType.GIF);
        Navigator.of(context).pop();
        break;
      case "txt":
        await FileSaver.instance.saveFile(filename, filedata, '.txt', mimeType: MimeType.TEXT);
        Navigator.of(context).pop();
        break;
      case "pdf":
        await FileSaver.instance.saveFile(filename, filedata, '.pdf', mimeType: MimeType.PDF);
        Navigator.of(context).pop();
        break;
      case "zip":
        await FileSaver.instance.saveFile(filename, filedata, '.zip', mimeType: MimeType.ZIP);
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
        SlimyCard(
          color: Colors.grey[200],
          width: 300,
          topCardHeight: 400,
          bottomCardHeight: 100,
          topCardWidget: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Scan QR-Code from Saifu App"),
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300, maxHeight: 250),
                  child: QrCodeCameraWeb(
                    fit: BoxFit.contain,
                    qrCodeCallback: (scanData) async {
                      if (mounted && percentage != 100) {
                        webcamQRData.add(scanData);
                        final decoded = jsonDecode(scanData);

                        if (firstScan == true) {
                          // We capture the maximum amount of frames we require, before this is modified on next frame reuests
                          originalMax = int.parse(decoded['max']);
                          // No longer needed after we capture it.
                          firstScan = false;
                        }
                        maxFrames = int.parse(decoded['max']);

                        var datasize = int.parse(webcamQRData.toSet().length.toString());
                        setState(() {
                          percentage = (datasize / originalMax) * 100;
                        });
                        if (percentage == 100) {
                          setState(() {
                            downloadeddata = webcamQRData.toSet().toList();
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
            ],
          ),
          bottomCardWidget: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(primary: Colors.white),
                  onPressed: () async {
                    setState(() {
                      list = List<int>.generate(originalMax, (i) => i + 1);
                      webcamQRData = webcamQRData.toSet().toList();
                    });

                    for (int i = 0; i < webcamQRData.length; i++) {
                      var data = jsonDecode(webcamQRData[i]);
                      list.remove(data['page']);
                    }
                    List stdMsgData = [];
                    List<List<int>> missedFrames = [];
                    for (var i = 0; i < list.length; i++) {
                      // var pageCount = i + 1;
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
            ],
          ),
        ),
      ],
    );
  }
}
