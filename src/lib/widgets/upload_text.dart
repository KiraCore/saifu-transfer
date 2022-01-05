import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:saifu_air/services/file_transfer_services.dart';
import 'package:saifu_air/utils/checksum_emojis.dart';
import 'package:saifu_air/utils/saifu_fast_qr.dart';
import 'package:image/image.dart' as Img;
import 'package:barcode_image/barcode_image.dart';
import 'package:saifu_air/widgets/secure_dialog.dart';
import 'package:saifu_air/widgets/upload_request_dialog.dart';

class UploadText extends StatefulWidget {
  dynamic textData;

  UploadText({this.textData});
  @override
  _UploadTextState createState() => _UploadTextState();
}

class _UploadTextState extends State<UploadText> {
  List<String> stdMsgData = [];
  List<int> missedFrames = [];
  bool encrypted = false;
  bool expandedTile = false;
  bool loading = false;
  String checksum = '';
  String base64data = '';

  Future<void> generateInitialFrames(var fileBytes, var split) async {
    var convertToBytes = utf8.encode(fileBytes);
    base64data = FileTransferServices().generateBase64data(convertToBytes);
    checksum = sha256.convert(utf8.encode(base64data)).toString();
    List<String> transferData = FileTransferServices().generateStringFrames(base64data, split);
    sortFrames(transferData);
  }

  void generateFrames(String qrData, var split) {
    checksum = sha256.convert(utf8.encode(base64data)).toString();
    List<String> processdata = FileTransferServices().generateStringFrames(qrData, split);
    sortFrames(processdata);
  }

  Future<void> downloadGif() async {
    Img.Animation animation = Img.Animation();
    for (int i = 0; i < stdMsgData.length; i++) {
      Img.Image image = Img.Image.rgb(500, 500);
      Img.fill(image, Img.getColor(255, 255, 255));
      drawBarcode(image, Barcode.qrCode(errorCorrectLevel: BarcodeQRCorrectionLevel.medium), stdMsgData[i], width: 450, height: 450, x: 25, y: 25);
      for (int i = 0; i < 1; i++) {
        animation.addFrame(image);
      }
    }
    var gifAnimation = Img.encodeGifAnimation(animation);
    var gifData = Uint8List.fromList(gifAnimation);
    await FileSaver.instance.saveFile("SHA:$checksum", gifData, '.gif', mimeType: MimeType.GIF);
    setState(() {
      loading = false;
    });
  }

  void sortFrames(var processdata) {
    List<dynamic> framesData = [];
    stdMsgData = [];
    for (var i = 0; i < processdata.length; i++) {
      var pageCount = i + 1;
      if (missedFrames.isEmpty) {
        if (i == 0) {
          framesData = ["temporary", "txt", processdata.length, pageCount, processdata[i], checksum, processdata.length, encrypted ? 0 : 1];
          var jsonFrame = jsonEncode(framesData);
          stdMsgData.add(jsonFrame);
        } else if (i != 0) {
          framesData = [[], [], processdata.length, pageCount, processdata[i], [], processdata.length, encrypted ? 0 : 1];
          var jsonFrame = jsonEncode(framesData);
          stdMsgData.add(jsonFrame);
        }
      } else {
        if (i == 0 && missedFrames.contains(pageCount)) {
          framesData = ["temporary", "txt", processdata.length, pageCount, processdata[i], checksum, missedFrames.length, encrypted ? 0 : 1];
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
    generateInitialFrames(widget.textData, 200);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Wrap(
            direction: Axis.horizontal,
            alignment: WrapAlignment.center,
            spacing: 30,
            children: [
              Container(
                height: 400,
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
                                                      "SHA256: " + snapshot.data[0],
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
                    Stack(
                      children: [
                        Container(
                          height: 330,
                          width: 320,
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                              color: encrypted ? Colors.red : Colors.grey[100],
                              borderRadius: BorderRadius.all(
                                Radius.circular(20.0),
                              )),
                          child: SaifuFastQR(
                            data: stdMsgData,
                          ),
                        ),
                        Positioned.fill(
                          child: Align(
                              alignment: Alignment.bottomCenter,
                              child: encrypted
                                  ? Container(
                                      padding: const EdgeInsets.all(5.0),
                                      decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey),
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(20.0),
                                          )),
                                      child: Icon(
                                        Icons.lock_outlined,
                                        size: 30,
                                        color: Colors.red,
                                      ),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.all(5.0),
                                      decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey),
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(20.0),
                                          )),
                                      child: Icon(
                                        Icons.lock_open_outlined,
                                        size: 30,
                                        color: Colors.black,
                                      ),
                                    )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              MediaQuery.of(context).size.width < 830
                  ? Column(
                      children: [
                        Wrap(
                          direction: Axis.horizontal,
                          alignment: WrapAlignment.start,
                          spacing: 10,
                          runSpacing: 10,
                          children: [
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
                              height: 5,
                            ),
                            Visibility(
                              visible: missedFrames.length == 0,
                              child: SizedBox(
                                width: 200,
                                child: ElevatedButton.icon(
                                  icon: Icon(
                                    Icons.security_outlined,
                                    color: Colors.red,
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
                              height: 5,
                            ),
                            SizedBox(
                              width: 200,
                              child: ElevatedButton.icon(
                                icon: Icon(
                                  Icons.gif_rounded,
                                  color: Colors.blue,
                                ),
                                label: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(
                                    "Download it as a GIF",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                                onPressed: () {
                                  downloadGif();
                                },
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
                      ],
                    )
                  : Container(
                      height: 450,
                      width: 220,
                      child: IntrinsicWidth(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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
                                    color: Colors.red,
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
                                  Icons.gif_rounded,
                                  color: Colors.blue,
                                  size: 35,
                                ),
                                label: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(
                                    "Download it as a GIF",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                                onPressed: () {
                                  downloadGif();
                                },
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
        ],
      ),
    );
  }
}
