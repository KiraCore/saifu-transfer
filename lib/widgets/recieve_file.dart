import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:saifu_air/utils/webcam/qr_code_scanner_web.dart';
import 'package:slimy_card/slimy_card.dart';

class RecieveFile extends StatefulWidget {
  RecieveFile({Key key}) : super(key: key);

  @override
  _RecieveFileState createState() => _RecieveFileState();
}

class _RecieveFileState extends State<RecieveFile> {
  List<String> webcamQRData = [];
  double percentage = 0;
  Uint8List filedata;
  var downloadeddata;
  var filename;
  var filetype;

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
      if (i == 0) {
        setState(() {
          filename = dataset[i]['name'];
          filetype = dataset[i]['type'];
          print(filetype);
        });
      } else {
        var dataValue = dataset[i]['data'];
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
      case "mpeg":
        await FileSaver.instance.saveFile(filename, filedata, '.mp3', mimeType: MimeType.MP3);
        Navigator.of(context).pop();
        break;
      default:
        Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 110,
        width: 150,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(52, 74, 230, 1),
                Color.fromRGBO(52, 74, 230, 1),
                Color.fromRGBO(41, 141, 255, 1),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            color: Color.fromRGBO(41, 141, 255, 0.5),
            //color: highlighted1 ? Colors.green : Colors.red,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MaterialButton(
                      onPressed: () async {
                        showDialog(
                            context: context,
                            builder: (context) => StatefulBuilder(builder: (context, setState) {
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
                                                        final decoded = jsonDecode(scanData);
                                                        int max = int.parse(decoded['max']);
                                                        var datasize = int.parse(webcamQRData.toSet().length.toString());
                                                        setState(() {
                                                          percentage = (datasize / max) * 100;
                                                          webcamQRData.add(scanData);
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
                                                percentage.toStringAsFixed(0) + "%",
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          )),
                                    ],
                                  );
                                }));
                      },
                      color: Colors.white,
                      textColor: Colors.white,
                      child: const Icon(
                        Icons.qr_code_2_rounded,
                        size: 24,
                        color: Colors.black,
                      ),
                      padding: const EdgeInsets.all(16),
                      shape: const CircleBorder(),
                    ),
                  ),
                  Column(
                    children: const [
                      Text("Recieve files", style: TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
