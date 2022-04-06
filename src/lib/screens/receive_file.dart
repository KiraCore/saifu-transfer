// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';

import 'package:image/image.dart' as img;
import 'package:barcode_image/barcode_image.dart';
import 'package:saifu_transfer/services/file_transfer.dart';
import 'package:saifu_transfer/widgets/emoji_widget.dart';
import 'package:saifu_transfer/widgets/secure_dialog.dart';
import 'package:saifu_transfer/widgets/title_widget.dart';
import 'package:saifu_transfer/widgets/upload_request_dialog.dart';
import 'package:saifu_qr/saifu_qr.dart';

// ignore: must_be_immutable
class ReceiveFile extends StatefulWidget {
  List<String> qrData = [];
  bool encrypted;
  String checksum = '';

  ReceiveFile({Key key, this.qrData, this.encrypted, this.checksum}) : super(key: key);

  @override
  State<ReceiveFile> createState() => _ReceiveFileState();
}

class _ReceiveFileState extends State<ReceiveFile> {
  List<String> stdMsgData = [];
  List<int> missedFrames = [];
  String checksum = '';
  String fileName = "";
  String fileType = "";
  String base64data = '';
  bool encrypted = false;

  void generateInitialFrames(List<String> qrData, bool encryped) {
    // Recieved QR code data in the format of List<String> Data.
    // We need to break down the structure to get base64 data
    String data = "";
    var dataset = [];
    for (var i = 0; i < qrData.length; i++) {
      var decodeJson = json.decode(qrData[i]);
      dataset.add(decodeJson);
    }
    dataset.sort((m1, m2) {
      return m1[3].compareTo(m2[3]);
    });
    for (var i = 0; i < dataset.length; i++) {
      var dataValue = "";
      if (i == 0) {
        fileName = dataset[i][0];
        fileType = dataset[i][1];
        dataValue = dataset[i][4];
        data = data + dataValue;
      } else if (i != 0) {
        dataValue = dataset[i][4];
        data = data + dataValue;
      }
    }
    base64data = data;
    generateFrames(base64data, 200);
  }

  void sortFrames(var processQrData) {
    List<dynamic> framesData = [];
    stdMsgData = [];
    for (var i = 0; i < processQrData.length; i++) {
      var pageCount = i + 1;
      if (missedFrames.isEmpty) {
        if (i == 0) {
          framesData = [fileName, fileType, processQrData.length, pageCount, processQrData[i], checksum, processQrData.length, widget.encrypted ? 0 : 1];
          var jsonFrame = jsonEncode(framesData);
          stdMsgData.add(jsonFrame);
        } else if (i != 0) {
          framesData = [[], [], processQrData.length, pageCount, processQrData[i], [], processQrData.length, widget.encrypted ? 0 : 1];
          var jsonFrame = jsonEncode(framesData);
          stdMsgData.add(jsonFrame);
        }
      } else {
        if (i == 0 && missedFrames.contains(pageCount)) {
          framesData = [fileName, fileType, processQrData.length, pageCount, processQrData[i], checksum, missedFrames.length, widget.encrypted ? 0 : 1];
          var jsonFrame = jsonEncode(framesData);
          stdMsgData.add(jsonFrame);
        } else if (i != 0 && missedFrames.contains(pageCount)) {
          framesData = [[], [], processQrData.length, pageCount, processQrData[i], [], missedFrames.length, widget.encrypted ? 0 : 1];
          var jsonFrame = jsonEncode(framesData);
          stdMsgData.add(jsonFrame);
        }
      }
    }
  }

  void generateFrames(String qrData, var split) {
    checksum = sha256.convert(utf8.encode(base64data)).toString();
    List<String> processQrData = FileTransferServices().generateStringFrames(qrData, split);
    sortFrames(processQrData);
  }

  downloadGif() async {
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

  Future<void> downloadFile(var fileBytes) async {
    switch (fileType) {
      case "avi":
        await FileSaver.instance.saveFile(fileName, fileBytes, '.avi', mimeType: MimeType.AVI);
        break;
      case "bmp":
        await FileSaver.instance.saveFile(fileName, fileBytes, '.bmp', mimeType: MimeType.BMP);
        break;
      case "epub":
        await FileSaver.instance.saveFile(fileName, fileBytes, '.epub', mimeType: MimeType.EPUB);
        break;
      case "gif":
        await FileSaver.instance.saveFile(fileName, fileBytes, '.gif', mimeType: MimeType.GIF);
        break;
      case "json":
        await FileSaver.instance.saveFile(fileName, fileBytes, '.json', mimeType: MimeType.JSON);
        break;
      case "mpeg":
        await FileSaver.instance.saveFile(fileName, fileBytes, '.mpeg', mimeType: MimeType.MPEG);
        break;
      case "mp3":
        await FileSaver.instance.saveFile(fileName, fileBytes, '.mp3', mimeType: MimeType.MP3);
        break;
      case "otf":
        await FileSaver.instance.saveFile(fileName, fileBytes, '.otf', mimeType: MimeType.OTF);
        break;
      case "png":
        await FileSaver.instance.saveFile(fileName, fileBytes, '.png', mimeType: MimeType.PNG);
        break;
      case "zip":
        await FileSaver.instance.saveFile(fileName, fileBytes, '.zip', mimeType: MimeType.ZIP);
        break;
      case "ttf":
        await FileSaver.instance.saveFile(fileName, fileBytes, '.ttf', mimeType: MimeType.TTF);
        break;
      case "rar":
        await FileSaver.instance.saveFile(fileName, fileBytes, '.rar', mimeType: MimeType.RAR);
        break;
      case "jpeg":
      case "jpg":
      case "jpe":
      case "jfif":
        await FileSaver.instance.saveFile(fileName, fileBytes, '.jpeg', mimeType: MimeType.JPEG);
        break;
      case "aac":
        await FileSaver.instance.saveFile(fileName, fileBytes, '.aac', mimeType: MimeType.AAC);
        break;
      case "pdf":
        await FileSaver.instance.saveFile(fileName, fileBytes, '.pdf', mimeType: MimeType.PDF);
        break;
      case "ods":
        await FileSaver.instance.saveFile(fileName, fileBytes, '.ods', mimeType: MimeType.OPENDOCSHEETS);
        break;
      case "odp":
        await FileSaver.instance.saveFile(fileName, fileBytes, '.odp', mimeType: MimeType.OPENDOCPRESENTATION);
        break;
      case "odt":
        await FileSaver.instance.saveFile(fileName, fileBytes, '.odt', mimeType: MimeType.OPENDOCTEXT);
        break;
      case "docx":
        await FileSaver.instance.saveFile(fileName, fileBytes, '.docx', mimeType: MimeType.MICROSOFTWORD);
        break;
      case "xlsx":
        await FileSaver.instance.saveFile(fileName, fileBytes, '.xlsx', mimeType: MimeType.MICROSOFTEXCEL);
        break;
      case "pptx":
        await FileSaver.instance.saveFile(fileName, fileBytes, '.pptx', mimeType: MimeType.MICROSOFTPRESENTATION);
        break;
      case "txt":
      case "plain":
        await FileSaver.instance.saveFile(fileName, fileBytes, '.txt', mimeType: MimeType.TEXT);
        break;
      case "csv":
        await FileSaver.instance.saveFile(fileName, fileBytes, '.csv', mimeType: MimeType.CSV);
        break;
      case "asice":
        await FileSaver.instance.saveFile(fileName, fileBytes, '.asice', mimeType: MimeType.ASICE);
        break;
      case "wav":
        await FileSaver.instance.saveFile(fileName, fileBytes, '.wav', mimeType: MimeType.OTHER);
        break;
      case "svg":
      case "svg+xml":
        await FileSaver.instance.saveFile(fileName, fileBytes, '.svg', mimeType: MimeType.OTHER);
        break;
      case "tif":
      case "tiff":
        await FileSaver.instance.saveFile(fileName, fileBytes, '.tif', mimeType: MimeType.OTHER);
        break;
      case "webp":
        await FileSaver.instance.saveFile(fileName, fileBytes, '.webp', mimeType: MimeType.OTHER);
        break;
      default:
        await FileSaver.instance.saveFile(fileName, fileBytes, '.$fileType', mimeType: MimeType.OTHER);
    }
  }

  @override
  void initState() {
    generateInitialFrames(widget.qrData, widget.encrypted);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            child: SafeArea(
                child: Padding(
                    padding: const EdgeInsets.all(50.0),
                    child: Column(children: [
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
                              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
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
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
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
                                      SizedBox(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Wrap(
                                            direction: Axis.horizontal,
                                            alignment: WrapAlignment.spaceBetween,
                                            children: [
                                              Text(fileName, overflow: TextOverflow.ellipsis),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const Divider(),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Column(children: [
                                        Container(
                                            width: 250,
                                            decoration: BoxDecoration(
                                                gradient: LinearGradient(colors: [Color.fromRGBO(52, 74, 230, 1), Color.fromRGBO(41, 141, 255, 0.67)], begin: Alignment.centerLeft, end: Alignment.centerRight),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(10),
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey.withOpacity(0.1),
                                                    spreadRadius: 2,
                                                    blurRadius: 7,
                                                    offset: Offset(0, 3),
                                                  )
                                                ]),
                                            child: ElevatedButton.icon(
                                                icon: Icon(Icons.security_rounded, color: Colors.white),
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
                                                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)))),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        SizedBox(
                                          width: 250,
                                          child: ElevatedButton.icon(
                                              icon: const Icon(Icons.search_rounded, color: Colors.black),
                                              label: const Padding(padding: EdgeInsets.all(12.0), child: SizedBox(width: 200, child: Text("Request missed frames", style: TextStyle(color: Colors.black)))),
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
                                              style: ElevatedButton.styleFrom(primary: Colors.grey[50], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)))),
                                        ),
                                        const SizedBox(height: 10),
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
                                                    ))))
                                      ])
                                    ]))
                              ])))
                    ])))));
  }
}
