import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:saifu_air/modal/file_model.dart';
import 'package:saifu_air/services/file_transfer_services.dart';
import 'package:saifu_air/utils/checksum_emojis.dart';
import 'package:saifu_air/utils/saifu_fast_qr.dart';
import 'package:saifu_air/widgets/secure_dialog.dart';
import 'package:saifu_air/widgets/upload_request_dialog.dart';

// ignore: must_be_immutable
class UploadFile extends StatefulWidget {
  dynamic fileData;
  FileInformation file;

  UploadFile({this.fileData, this.file});

  @override
  State<UploadFile> createState() => _UploadFileState();
}

class _UploadFileState extends State<UploadFile> {
  List<String> stdMsgData = [];
  List<int> missedFrames = [];
  bool expandedTile = false;
  bool encrypted = false;
  String base64data = '';
  String checksum = '';

  Future<void> generateInitialFrames(var fileBytes, var split) async {
    base64data = FileTransferServices().generateBase64data(fileBytes);
    checksum = sha256.convert(utf8.encode(base64data)).toString();
    List<String> transferData = FileTransferServices().generateStringFrames(base64data, split);
    sortFrames(transferData);
  }

  void generateFrames(String qrData, var split) {
    checksum = sha256.convert(utf8.encode(base64data)).toString();
    List<String> processdata = FileTransferServices().generateStringFrames(qrData, split);
    sortFrames(processdata);
  }

  void sortFrames(var processdata) {
    List<dynamic> framesData = [];
    stdMsgData = [];
    for (var i = 0; i < processdata.length; i++) {
      var pageCount = i + 1;
      if (missedFrames.isEmpty) {
        if (i == 0) {
          framesData = [widget.file.name, widget.file.mime, processdata.length, pageCount, processdata[i], checksum, processdata.length, encrypted ? 0 : 1];
          var jsonFrame = jsonEncode(framesData);
          stdMsgData.add(jsonFrame);
        } else if (i != 0) {
          framesData = [[], [], processdata.length, pageCount, processdata[i], [], processdata.length, encrypted ? 0 : 1];
          var jsonFrame = jsonEncode(framesData);
          stdMsgData.add(jsonFrame);
        }
      } else {
        if (i == 0 && missedFrames.contains(pageCount)) {
          framesData = [widget.file.name, widget.file.mime, processdata.length, pageCount, processdata[i], checksum, missedFrames.length, encrypted ? 0 : 1];
          var jsonFrame = jsonEncode(framesData);
          stdMsgData.add(jsonFrame);
        } else if (i != 0 && missedFrames.contains(pageCount)) {
          framesData = [[], [], processdata.length, pageCount, processdata[i], [], missedFrames.length, encrypted ? 0 : 1];
          var jsonFrame = jsonEncode(framesData);
          stdMsgData.add(jsonFrame);
        }
      }
    }
  }

  @override
  void initState() {
    generateInitialFrames(widget.fileData, 200);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Wrap(
        direction: Axis.horizontal,
        alignment: WrapAlignment.center,
        spacing: 30,
        children: [
          Container(
            height: 450,
            width: 350,
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                  width: 350,
                  child: FutureBuilder(
                      future: EmojiCheckSum.convertToEmoji(checksum),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black));
                          default:
                            if ((snapshot.hasError)) {
                              return Center(child: Text("Issue related to EmojiSum"));
                            } else {
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    expandedTile = !expandedTile;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    width: 200,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        expandedTile
                                            ? Flexible(
                                                child: Text(
                                                  snapshot.data[0],
                                                  style: TextStyle(fontSize: 15, color: Colors.black),
                                                  textAlign: TextAlign.center,
                                                ),
                                              )
                                            : Flexible(
                                                child: Text(
                                                  snapshot.data[1],
                                                  style: TextStyle(fontSize: 20, color: Colors.black),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                        expandedTile ? Icon(Icons.keyboard_arrow_up_rounded) : Icon(Icons.keyboard_arrow_down_rounded)
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                        }
                      }),
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      )),
                  padding: const EdgeInsets.all(8.0),
                  child: SaifuFastQR(
                    itemHeight: 350,
                    data: stdMsgData,
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: missedFrames.length == 0
                        ? Text(
                            "THIS IS FULL FILE QRCODE ",
                            style: TextStyle(color: Colors.green, fontSize: 14),
                            textAlign: TextAlign.center,
                          )
                        : Text(
                            "THIS IS MODIFIED QR-CODE",
                            style: TextStyle(color: Colors.red, fontSize: 14),
                            textAlign: TextAlign.center,
                          )),
              ],
            ),
          ),
          Container(
            height: 450,
            width: 220,
            child: IntrinsicWidth(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Name: " + widget.file.name + "\n" + "Size: " + widget.file.size + "\n" "Type: " + widget.file.mime,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton.icon(
                      icon: Icon(
                        Icons.search_rounded,
                        color: Colors.purple,
                      ),
                      label: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          "Request missed frames",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      onPressed: () async {
                        missedFrames = [];
                        var data = await showDialog(barrierColor: Colors.transparent, context: context, builder: (_) => UploadRequestDialog());

                        try {
                          if (data != false) {
                            var jsonData = [];
                            for (var i = 0; i < data.length; i++) {
                              var decodeJson = json.decode(data[i]);
                              jsonData.add(decodeJson);
                              List<int> list = decodeJson[4].cast<int>();
                              list.forEach((item) => missedFrames.add(item));
                            }
                            missedFrames.sort();
                            setState(() {
                              generateFrames(base64data, 200);
                            });
                          } else {}
                        } catch (e) {
                          print(e);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Visibility(
                    visible: missedFrames.length == 0,
                    child: SizedBox(
                      width: 200,
                      child: ElevatedButton.icon(
                        icon: Icon(
                          Icons.security_outlined,
                          color: Colors.amber,
                        ),
                        label: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: encrypted
                              ? Text(
                                  "Unlock file with a Password",
                                  style: TextStyle(color: Colors.black),
                                )
                              : Text(
                                  "Secure it with a Password",
                                  style: TextStyle(color: Colors.black),
                                ),
                        ),
                        onPressed: () async {
                          if (encrypted) {
                            dynamic data = await showDialog(barrierDismissible: false, context: context, builder: (_) => SecureDialog(base64data, encrypted));
                            if (data == false) {
                            } else {
                              setState(() {
                                encrypted = false;
                                base64data = data;
                              });
                              generateFrames(data, 200);
                            }
                          } else {
                            dynamic data = await showDialog(barrierDismissible: false, context: context, builder: (_) => SecureDialog(base64data, encrypted));
                            if (data == false) {
                            } else {
                              setState(() {
                                encrypted = true;
                                base64data = data;
                              });
                              generateFrames(data, 200);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton.icon(
                      icon: Icon(
                        Icons.file_download_outlined,
                        color: Colors.green,
                      ),
                      label: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          "Download it as a GIF",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
