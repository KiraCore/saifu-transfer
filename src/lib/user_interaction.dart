import 'dart:convert';
import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:saifu_air/utils/checksum_emojis.dart';
import 'package:saifu_air/widgets/droppedFile_widget.dart';
import 'package:saifu_air/modal/dropped_file.dart';
import 'package:saifu_air/widgets/droppedZone_widget.dart';
import 'package:saifu_air/utils/saifu_fast_qr.dart';
import 'package:saifu_air/widgets/missed_frames_dialog.dart';
import 'package:saifu_air/widgets/recieve_file.dart';

// ignore: must_be_immutable
class UserInteraction extends StatefulWidget {
  UserInteraction({Key key}) : super(key: key);

  @override
  _UserInteractionState createState() => _UserInteractionState();
}

class _UserInteractionState extends State<UserInteraction> {
  bool uploadedFile = false;
  DropzoneViewController controller;
  DroppedFile file;
  List<String> stdMsgData = [];
  List<int> missedFrames = [];
  int max = 0;
  var checksum = "";

  Future<void> generateFrames(var data, var splitValue) async {
    //print(data);
    // Generate checkum of file bytes
    checksum = sha256.convert(data).toString();
    // Encode to Gzip compressions
    var gzipBytes = GZipEncoder().encode(data);
    RegExp frames = RegExp(".{1," + splitValue.toStringAsFixed(0) + "}");
    String str = base64.encode(gzipBytes);

    Iterable<Match> matches = frames.allMatches(str);
    var list = matches.map((m) => m.group(0)).toList();

    stdMsgData = [];
    Map<String, Object> framesData;

    for (var i = 0; i < list.length; i++) {
      var pageCount = i + 1;
      if (missedFrames.isEmpty) {
        if (i == 0) {
          framesData = {"name": file.name, "type": file.mime, "data": list[i], "checksum": checksum, "max": "${list.length}", "page": pageCount};
          var jsonFrame = jsonEncode(framesData);
          stdMsgData.add(jsonFrame);
        } else if (i != 0) {
          framesData = {"max": "${list.length}", "page": pageCount, "data": list[i]};
          var jsonFrame = jsonEncode(framesData);
          stdMsgData.add(jsonFrame);
        }
      } else {
        if (i == 0 && missedFrames.contains(pageCount)) {
          framesData = {"name": file.name, "type": file.mime, "data": list[i], "checksum": checksum, "max": "${missedFrames.length}", "page": pageCount};
          var jsonFrame = jsonEncode(framesData);
          stdMsgData.add(jsonFrame);
        } else if (i != 0 && missedFrames.contains(pageCount)) {
          framesData = {"max": "${missedFrames.length}", "page": pageCount, "data": list[i]};
          var jsonFrame = jsonEncode(framesData);
          stdMsgData.add(jsonFrame);
        }
      }
    }
    print(stdMsgData);
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
                    setState(() {
                      missedFrames = [];
                    });
                    var filedata = await controller.getFileData(file.event);
                    //var compressedString = base64.encode(gzipBytes);
                    generateFrames(filedata, 100);
                    var checksumEmoji = await EmojiCheckSum.convertToEmoji(checksum);
                    bool expandedTile = false;
                    showDialog(
                        context: context,
                        builder: (context) => StatefulBuilder(builder: (context, setState) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 650,
                                    width: 400,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                      child: Scaffold(
                                          backgroundColor: Colors.white,
                                          body: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "Scan QR-Code",
                                                style: TextStyle(color: Colors.black, fontSize: 16),
                                              ),
                                              Spacer(),
                                              Center(
                                                child: Container(
                                                  decoration: new BoxDecoration(
                                                    color: Colors.grey[200],
                                                    shape: BoxShape.rectangle,
                                                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        decoration: new BoxDecoration(color: Colors.black, shape: BoxShape.rectangle, borderRadius: BorderRadius.all(Radius.circular(30.0))),
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: ExpansionTile(
                                                          iconColor: Colors.white,
                                                          collapsedIconColor: Colors.white,
                                                          title: expandedTile
                                                              ? Text(
                                                                  checksumEmoji[0],
                                                                  style: TextStyle(fontSize: 20),
                                                                  textAlign: TextAlign.center,
                                                                )
                                                              : Text(
                                                                  checksumEmoji[1],
                                                                  style: TextStyle(fontSize: 20),
                                                                  textAlign: TextAlign.center,
                                                                ),
                                                          onExpansionChanged: (bool expanded) {
                                                            setState(() {
                                                              expandedTile = expanded;
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                      SaifuFastQR(
                                                        data: stdMsgData,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Spacer(),
                                              Padding(
                                                padding: const EdgeInsets.all(20.0),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.transparent,
                                                    border: new Border.all(
                                                      color: Colors.grey[400],
                                                      width: 1,
                                                    ),
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(10),
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: Row(
                                                      children: [
                                                        Spacer(),
                                                        TextButton(
                                                          style: ButtonStyle(
                                                            overlayColor: MaterialStateProperty.all(Colors.transparent),
                                                          ),
                                                          onPressed: () async {
                                                            missedFrames = [];

                                                            var data = await showDialog(
                                                                context: context,
                                                                useRootNavigator: false,
                                                                builder: (context) {
                                                                  return MissedFrames();
                                                                });
                                                            var jsonData = [];
                                                            for (var i = 0; i < data.length; i++) {
                                                              var decodeJson = json.decode(data[i]);
                                                              jsonData.add(decodeJson);
                                                              List<int> list = decodeJson['data'].cast<int>();
                                                              list.forEach((item) => missedFrames.add(item));
                                                            }
                                                            missedFrames.sort();
                                                            setState(() {
                                                              generateFrames(filedata, 100);
                                                            });
                                                          },
                                                          child: Text(
                                                            "Specify Missed Frames",
                                                            style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
                                                          ),
                                                        ),
                                                        Spacer(),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )),
                                    ),
                                  ),
                                ],
                              );
                            }));
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
                      missedFrames = [];
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
