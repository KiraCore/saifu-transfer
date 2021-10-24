import 'dart:convert';

import 'package:archive/archive_io.dart';
import 'package:dotted_border/dotted_border.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';

import 'package:saifu_air/widgets/droppedFile_widget.dart';
import 'package:saifu_air/modal/dropped_file.dart';
import 'package:saifu_air/widgets/dropzone_widget.dart';
import 'package:saifu_air/utils/saifu_fast_qr.dart';
import 'package:saifu_air/widgets/recieve_file.dart';
import 'package:slimy_card/slimy_card.dart';

// ignore: must_be_immutable
class UserInteraction extends StatefulWidget {
  double percentage = 0;
  UserInteraction({Key key}) : super(key: key);

  @override
  _UserInteractionState createState() => _UserInteractionState();
}

class _UserInteractionState extends State<UserInteraction> {
  bool uploadedFile = false;
  DropzoneViewController controller;
  DroppedFile file;
  List<String> stdMsgData = [];

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
        framesData = {"name": file.name, "type": file.mime, "max": "${list.length}", "page": pageCount, "data": list[i]};
      } else {
        framesData = {"max": "${list.length}", "page": pageCount, "data": list[i]};
      }

      var jsonFrame = jsonEncode(framesData);
      stdMsgData.add(jsonFrame);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (uploadedFile == true) feedbackUi(context),
        SizedBox(
          height: 25,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            uploadData(),
            const SizedBox(
              width: 10,
            ),
            RecieveFile(),
          ],
        ),
      ],
    );
  }

  Row feedbackUi(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(20.0),
              )),
          padding: const EdgeInsets.all(8.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            DroppedFileWidget(
              file: file,
              controller: controller,
            ),
            SizedBox(
              width: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    child: Text(
                      file.name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  Text(
                    file.size,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ]),
        ),
        const SizedBox(
          width: 10,
        ),
        Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(30.0),
                  )),
              child: IconButton(
                  onPressed: () async {
                    var data = await controller.getFileData(file.event);
                    var gzipBytes = GZipEncoder().encode(data);
                    //var compressedString = base64.encode(gzipBytes);
                    processData(gzipBytes, 100);

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
                                          Text("Scan QR-Code into Saifu App"),
                                          Container(
                                            decoration: const BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(30.0),
                                                )),
                                            height: 300,
                                            width: 300,
                                            child: Center(
                                              child: SaifuFastQR(
                                                transitionDuration: 100,
                                                itemHeight: 300,
                                                itemWidth: 300,
                                                data: stdMsgData,
                                              ),
                                            ),
                                          )
                                        ],
                                      )),
                                ],
                              );
                            }));
/*
                    showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            content: Container(
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(30.0),
                                  )),
                              height: 300,
                              width: 300,
                              child: Center(
                                child: SaifuFastQR(
                                  transitionDuration: 100,
                                  itemHeight: 300,
                                  itemWidth: 300,
                                  data: stdMsgData,
                                ),
                              ),
                            )));

                            */
                  },
                  icon: const Icon(Icons.check_rounded)),
            ),
            const SizedBox(
              height: 5,
            ),
            Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(30.0),
                  )),
              child: IconButton(
                  onPressed: () {
                    setState(() {
                      uploadedFile = false;
                    });
                  },
                  icon: const Icon(Icons.close_rounded)),
            ),
          ],
        ),
      ],
    );
  }

  DottedBorder uploadData() {
    return DottedBorder(
      color: Colors.white,
      dashPattern: const [7, 7],
      borderType: BorderType.RRect,
      strokeCap: StrokeCap.round,
      strokeWidth: 0.5,
      radius: const Radius.circular(20),
      padding: const EdgeInsets.all(6),
      child: SizedBox(
        height: 110,
        width: 150,
        child: DropzoneWidget(
          onDroppedDropzoneViewController: (controller) => setState(() => this.controller = controller),
          onDroppedFIle: (file) => {
            setState(
              () {
                this.file = file;
                uploadedFile = true;
              },
            ),
            /*
                                    showDialog(
                                        barrierColor: Colors.transparent,
                                        context: context,
                                        builder: (_) => AlertDialog(
                                            backgroundColor: Colors.transparent,
                                            elevation: 0,
                                            content: StepperDialog(
                                              file: file,
                                              controller: controller,
                                            )))
                                            */
          },
        ),
      ),
    );
  }
}
