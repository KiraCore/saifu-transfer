import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:saifu_air/modal/file_model.dart';
import 'package:saifu_air/widgets/upload_text_dialog.dart';
import 'package:saifu_air/widgets/upload_text.dart';
import 'package:saifu_air/widgets/qr_code_file_transfer.dart';
import 'package:saifu_air/widgets/Receive_file.dart';
import 'package:saifu_air/widgets/upload_file.dart';

// ignore: must_be_immutable
class DropZone extends StatefulWidget {
  bool fileDropped = false;
  bool receivedFile = false;
  bool textFile = false;
  FileInformation file;
  @override
  State<DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<DropZone> {
  List<String> checkSumEmoji = [];
  DropzoneViewController controller;
  bool highlighted1 = false;
  List<String> qrData = [];
  String textData = "";
  String message1 = '';
  dynamic droppedEv;
  bool encrypted = false;

  Future acceptFile(dynamic event) async {
    final name = event.name;
    final type = await controller.getFileMIME(event);
    final bytes = await controller.getFileSize(event);
    final url = await controller.createFileUrl(event);
    var fileData = await controller.getFileData(event);

    widget.file = FileInformation(url: url, name: name, mime: type.split('/')[1], bytes: bytes, event: event);

    return fileData;
  }

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      color: highlighted1 ? Colors.blue : Colors.red,
      dashPattern: const [7, 7],
      borderType: BorderType.RRect,
      strokeCap: StrokeCap.round,
      strokeWidth: 1,
      radius: const Radius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(20.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: widget.receivedFile == true
                ? Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20.0),
                            child: IconButton(
                              icon: Icon(Icons.navigate_before),
                              onPressed: () => setState(() {
                                highlighted1 = false;
                                widget.receivedFile = false;
                              }),
                            ),
                          ),
                        ],
                      ),
                      ReceiveFile(
                        qrData: qrData,
                        encrypted: encrypted,
                      ),
                    ],
                  )
                : widget.fileDropped
                    ? FutureBuilder(
                        future: acceptFile(droppedEv),
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(20.0),
                                        child: IconButton(
                                          icon: Icon(Icons.navigate_before),
                                          onPressed: () => setState(() {
                                            widget.fileDropped = false;
                                            highlighted1 = false;
                                          }),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Center(
                                        child: Image.asset(
                                      "assets/loading.gif",
                                      height: 250.0,
                                      width: 250.0,
                                    )),
                                  ),
                                ],
                              );
                            default:
                              if ((snapshot.hasError)) {
                                return Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(20.0),
                                          child: IconButton(
                                            icon: Icon(Icons.navigate_before),
                                            onPressed: () => setState(() {
                                              widget.fileDropped = false;
                                              highlighted1 = false;
                                            }),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Center(child: Text("Uploading file failed, Try again")),
                                  ],
                                );
                              } else {
                                return Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(20.0),
                                          child: IconButton(
                                            icon: Icon(Icons.navigate_before),
                                            onPressed: () => setState(() {
                                              widget.fileDropped = false;
                                              highlighted1 = false;
                                            }),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      child: UploadFile(
                                        file: widget.file,
                                        fileData: snapshot.data,
                                      ),
                                    ),
                                  ],
                                );
                              }
                          }
                        })
                    : widget.textFile
                        ? Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20.0),
                                    child: IconButton(
                                      icon: Icon(Icons.navigate_before),
                                      onPressed: () => setState(() {
                                        widget.receivedFile = false;
                                        widget.fileDropped = false;
                                        widget.textFile = false;
                                      }),
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                  child: UploadText(
                                textData: textData,
                              )),
                            ],
                          )
                        : Stack(
                            children: [
                              DropzoneView(
                                operation: DragOperation.copy,
                                cursor: CursorType.grab,
                                onCreated: (ctrl) => controller = ctrl,
                                onError: (ev) => setState(() => message1 = 'Dropped down view Error'),
                                onHover: () {
                                  setState(() => highlighted1 = true);
                                },
                                onLeave: () {
                                  setState(() => highlighted1 = false);
                                },
                                onDrop: (ev) async {
                                  setState(() {
                                    droppedEv = ev;
                                    widget.fileDropped = true;
                                  });
                                },
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          "Drag and Drop here",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.black),
                                        ),
                                        Text(
                                          message1,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                                    SizedBox(
                                      width: 100,
                                      child: new Container(
                                          margin: const EdgeInsets.only(left: 10.0, right: 20.0),
                                          child: Divider(
                                            color: Colors.black,
                                            height: 36,
                                          )),
                                    ),
                                    Text("OR"),
                                    SizedBox(
                                      width: 100,
                                      child: new Container(
                                          margin: const EdgeInsets.only(left: 20.0, right: 10.0),
                                          child: Divider(
                                            color: Colors.black,
                                            height: 36,
                                          )),
                                    ),
                                  ]),
                                  SizedBox(
                                    height: 25,
                                  ),
                                  Wrap(
                                    direction: Axis.horizontal,
                                    alignment: WrapAlignment.center,
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          dynamic data = await showDialog(barrierDismissible: false, context: context, builder: (_) => TextDialog());
                                          setState(() {
                                            widget.receivedFile = false;
                                            widget.fileDropped = false;
                                            widget.textFile = true;
                                            textData = data;
                                          });
                                        },
                                        child: Container(
                                          width: 125,
                                          height: 100,
                                          padding: const EdgeInsets.all(15.0),
                                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Color.fromRGBO(0, 26, 69, 0.1))),
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: RotatedBox(
                                                  quarterTurns: 1,
                                                  child: Icon(
                                                    Icons.link_rounded,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                "Paste text data",
                                                style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w100),
                                                textAlign: TextAlign.center,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          var data = await showDialog(barrierDismissible: false, barrierColor: Colors.transparent, context: context, builder: (_) => QrCodeFileTransfer());
                                          if (data == false) return;
                                          setState(() {
                                            widget.receivedFile = true;
                                            widget.fileDropped = false;
                                            qrData = data[0];
                                            encrypted = data[1];
                                          });
                                        },
                                        child: Container(
                                          width: 125,
                                          height: 100,
                                          padding: const EdgeInsets.all(15.0),
                                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.blue)),
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: Icon(
                                                  Icons.qr_code_scanner,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              Text(
                                                "Receive a File",
                                                style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w100),
                                                textAlign: TextAlign.center,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          final events = await controller.pickFiles();
                                          //acceptFile(events.first);
                                          if (events.isEmpty) return;
                                          setState(() {
                                            droppedEv = events.first;
                                            widget.fileDropped = true;
                                          });
                                        },
                                        child: Container(
                                          width: 125,
                                          height: 100,
                                          padding: const EdgeInsets.all(15.0),
                                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.blue)),
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: Icon(
                                                  Icons.file_upload_outlined,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              Text(
                                                "Upload a File",
                                                style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w100),
                                                textAlign: TextAlign.center,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          )),
      ),
    );
  }
}
