// ignore_for_file: must_be_immutable, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:file_saver/file_saver.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:saifu_air/file_model.dart';
import 'package:saifu_air/services/file_transfer.dart';
import 'package:saifu_air/widgets/emoji_widget.dart';
import 'package:saifu_air/widgets/secure_dialog.dart';
import 'package:saifu_air/widgets/title_widget.dart';
import 'package:saifu_air/widgets/upload_request_dialog.dart';
import 'package:saifu_qr/saifu_qr.dart';
import 'package:image/image.dart' as img;
import 'package:barcode_image/barcode_image.dart';

class UploadedFile extends StatefulWidget {
  FileInformation file;
  UploadedFile({Key key, this.file}) : super(key: key);

  @override
  State<UploadedFile> createState() => _UploadedFileState();
}

class _UploadedFileState extends State<UploadedFile> {
  DropzoneViewController controller;
  String base64data = '';
  String checksum = '';
  List<String> stdMsgData = [];
  List<int> missedFrames = [];
  bool encrypted = false;

  @override
  void initState() {
    generateInitialFrames(widget.file.data, 200);
    super.initState();
  }

  Future<void> generateInitialFrames(var fileBytes, var split) async {
    base64data = FileTransferServices().generateBase64data(fileBytes);
    checksum = sha256.convert(utf8.encode(base64data)).toString();
    List<String> transferData = FileTransferServices().generateStringFrames(base64data, split);
    sortFrames(transferData);
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

  void generateFrames(String qrData, var split) {
    checksum = sha256.convert(utf8.encode(base64data)).toString();
    List<String> processdata = FileTransferServices().generateStringFrames(qrData, split);
    sortFrames(processdata);
  }

  Future<void> downloadGif() async {
    img.Animation animation = img.Animation();
    for (int i = 0; i < stdMsgData.length; i++) {
      img.Image image = img.Image.rgb(500, 500);
      img.fill(image, img.getColor(255, 255, 255));
      drawBarcode(image, Barcode.qrCode(errorCorrectLevel: BarcodeQRCorrectionLevel.medium), stdMsgData[i], width: 450, height: 450, x: 25, y: 25);
      for (int i = 0; i < 1; i++) {
        animation.addFrame(image);
      }
    }
    var gifAnimation = img.encodeGifAnimation(animation);
    var gifData = Uint8List.fromList(gifAnimation);
    await FileSaver.instance.saveFile("SHA:$checksum", gifData, '.gif', mimeType: MimeType.GIF);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    child: Container(
                      color: Colors.white,
                      child: const TitleWidget(),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(15.0),
                    child: SizedBox(
                      width: 500,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.all(15.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 100,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          icon: const Icon(Icons.navigate_before_outlined)),
                                      const Spacer(),
                                      EmojiWidget(checksum: checksum),
                                      const Spacer()
                                    ],
                                  ),
                                ),
                                encrypted
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                              decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(5)),
                                              padding: const EdgeInsets.all(8.0),
                                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                                Text(
                                                  "File is encrypted ",
                                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                ),
                                              ])),
                                        ],
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                              decoration: BoxDecoration(color: Colors.yellow, borderRadius: BorderRadius.circular(5)),
                                              padding: const EdgeInsets.all(8.0),
                                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                                Text(
                                                  "WARNING: File IS NOT encrypted ",
                                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                                ),
                                              ])),
                                        ],
                                      ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Stack(
                                  children: [
                                    Container(
                                      height: 330,
                                      padding: const EdgeInsets.all(20.0),
                                      decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0),
                                          )),
                                      child: SaifuQR(
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
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.all(
                                                        Radius.circular(20.0),
                                                      )),
                                                  child: Icon(
                                                    Icons.lock_outlined,
                                                    size: 30,
                                                    color: Colors.black,
                                                  ),
                                                )
                                              : Container(
                                                  padding: const EdgeInsets.all(5.0),
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.all(
                                                        Radius.circular(20.0),
                                                      )),
                                                  child: Icon(
                                                    Icons.lock_open,
                                                    size: 30,
                                                    color: Colors.black,
                                                  ),
                                                )),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Wrap(
                                      direction: Axis.horizontal,
                                      alignment: WrapAlignment.spaceBetween,
                                      children: [
                                        Text(widget.file.name, overflow: TextOverflow.ellipsis),
                                        Text(
                                          widget.file.size,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Divider(),
                                const SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  children: [
                                    Container(
                                        width: 250,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color.fromRGBO(52, 74, 230, 1),
                                              Color.fromRGBO(41, 141, 255, 0.67),
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.1),
                                              spreadRadius: 2,
                                              blurRadius: 7,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton.icon(
                                          icon: Icon(
                                            Icons.security_rounded,
                                            color: Colors.white,
                                          ),
                                          label: Padding(
                                            padding: EdgeInsets.all(12.0),
                                            child: SizedBox(
                                              width: 200,
                                              child: encrypted
                                                  ? Text(
                                                      "Unlock file with a Password",
                                                      style: TextStyle(color: Colors.white),
                                                    )
                                                  : Text(
                                                      "Secure it with a Password",
                                                      style: TextStyle(color: Colors.white),
                                                    ),
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
                                          style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                          ),
                                        )),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    SizedBox(
                                      width: 250,
                                      child: ElevatedButton.icon(
                                        icon: const Icon(
                                          Icons.search_rounded,
                                          color: Colors.black,
                                        ),
                                        label: const Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: SizedBox(
                                            width: 200,
                                            child: Text(
                                              "Request missed frames",
                                              style: TextStyle(color: Colors.black),
                                            ),
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
                                                for (var item in list) {
                                                  missedFrames.add(item);
                                                }
                                              }
                                              missedFrames.sort();
                                              setState(() {
                                                generateFrames(base64data, 200);
                                              });
                                            } else {}
                                          } catch (e) {
                                            log(e);
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.grey[50],
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    SizedBox(
                                      width: 250,
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.file_download_rounded, color: Colors.black),
                                        label: const Padding(
                                            padding: EdgeInsets.all(12.0),
                                            child: SizedBox(
                                              width: 200,
                                              child: Text("Download it as a GIF", style: TextStyle(color: Colors.black)),
                                            )),
                                        onPressed: () {
                                          downloadGif();
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
