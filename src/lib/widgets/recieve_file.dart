import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:saifu_air/services/file_transfer_services.dart';
import 'package:saifu_air/utils/checksum_emojis.dart';
import 'package:saifu_air/utils/saifu_fast_qr.dart';
import 'package:saifu_air/widgets/secure_dialog.dart';
import 'package:saifu_air/widgets/upload_request_dialog.dart';

// ignore: must_be_immutable
class RecieveFile extends StatefulWidget {
  List<String> qrData = [];
  bool encrypted;
  String checksum = '';

  RecieveFile({this.qrData, this.encrypted, this.checksum});

  @override
  State<RecieveFile> createState() => _RecieveFileState();
}

class _RecieveFileState extends State<RecieveFile> {
  List<String> stdMsgData = [];
  List<int> missedFrames = [];
  bool expandedTile = false;
  bool validChecksum = false;
  String checksum = '';
  String fileName = "";
  String fileType = "";
  String base64data = '';

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
    return Expanded(
      child: Padding(
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                        shape: BoxShape.rectangle,
                      ),
                      height: 350,
                      width: 350,
                      child: Swiper(
                        control: new SwiperControl(color: Colors.black),
                        pagination: new SwiperPagination(),
                        duration: 50,
                        autoplay: false,
                        itemCount: 2,
                        loop: false,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, int index) {
                          return Center(
                            child: index == 0
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      widget.encrypted
                                          ? Text("")
                                          : validChecksum
                                              ? Text(" ", style: TextStyle(color: Colors.green, fontSize: 20))
                                              : Text(
                                                  " ",
                                                  style: TextStyle(color: Colors.red, fontSize: 20),
                                                ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SaifuFastQR(
                                        itemHeight: 350,
                                        data: stdMsgData,
                                      ),
                                    ],
                                  ),
                          );
                        },
                      ),
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
                      fileName + "\n" + fileType,
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
                            child: widget.encrypted
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
                            if (widget.encrypted) {
                              dynamic data = await showDialog(barrierDismissible: false, context: context, builder: (_) => SecureDialog(base64data, widget.encrypted));
                              if (data == false) {
                              } else {
                                setState(() {
                                  widget.encrypted = false;
                                  base64data = data;
                                });
                                generateFrames(data, 200);
                              }
                            } else {
                              dynamic data = await showDialog(barrierDismissible: false, context: context, builder: (_) => SecureDialog(base64data, widget.encrypted));
                              if (data == false) {
                              } else {
                                setState(() {
                                  widget.encrypted = true;
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
                            "Download it",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        onPressed: () async {
                          if (widget.encrypted == true) {
                            dynamic data = await showDialog(barrierDismissible: false, context: context, builder: (_) => SecureDialog(base64data, widget.encrypted));
                            if (data == false) {
                            } else {
                              var decode = base64.decode(data);
                              var gzipBytes = GZipDecoder().decodeBytes(decode);
                              downloadFile(gzipBytes);
                            }
                          } else {
                            var decode = base64.decode(base64data);
                            var gzipBytes = GZipDecoder().decodeBytes(decode);
                            downloadFile(gzipBytes);
                          }
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
      ),
    );
  }
}
