import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:saifu_air/widgets/recieve_dialog.dart';

class RecieveFile extends StatefulWidget {
  RecieveFile({Key key}) : super(key: key);

  @override
  _RecieveFileState createState() => _RecieveFileState();
}

class _RecieveFileState extends State<RecieveFile> {
  Uint8List fileData;
  var scannedData;
  var filename;
  var filetype;

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

    for (var i = 0; i < dataset.length; i++) {
      var dataValue = "";
      if (i == 0) {
        setState(() {
          filename = dataset[i]['name'];
          filetype = dataset[i]['type'];
        });
        dataValue = dataset[i]['data'];
        data = data + dataValue;
      } else if (i != 0) {
        dataValue = dataset[i]['data'];
        data = data + dataValue;
      }
    }
    var decode = base64.decode(data);

    var gzipBytes = GZipDecoder().decodeBytes(decode);

    setState(() {
      fileData = gzipBytes;
    });
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
                                  return RecieveDialog();
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
