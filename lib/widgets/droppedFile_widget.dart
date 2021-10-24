// ignore_for_file: file_names

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:saifu_air/modal/dropped_file.dart';

// ignore: must_be_immutable
class DroppedFileWidget extends StatelessWidget {
  List<String> stdMsgData = [];
  final DroppedFile file;
  final DropzoneViewController controller;
  bool loading = false;
  DroppedFileWidget({Key key, this.file, this.controller}) : super(key: key);

  Future<void> processData(var data, var splitValue) async {
    //print(data);
    RegExp frames = new RegExp(".{1," + splitValue.toStringAsFixed(0) + "}");
    String str = base64.encode(data);
    Iterable<Match> matches = frames.allMatches(str);
    var list = matches.map((m) => m.group(0)).toList();
    stdMsgData = [];

    for (var i = 0; i < list.length; i++) {
      var pageCount = i + 1;
      var framesData;
      if (i == 0) {
        framesData = {"name": file.name, "type": file.mime, "max": "${list.length}", "page": pageCount, "data": list[i]};
      } else {
        framesData = {"max": "${list.length}", "page": pageCount, "data": list[i]};
      }

      var jsonFrame = jsonEncode(framesData);
      stdMsgData.add(jsonFrame);
    }
    print(stdMsgData);
  }

  @override
  Widget build(BuildContext context) => Row(
        children: [
          buildImage(),
        ],
      );

  Widget buildImage() {
    if (file == null) return buildEmptyFile('');

    return Image.network(
      file.url,
      width: 120,
      height: 120,
      fit: BoxFit.cover,
      errorBuilder: (context, error, _) => buildEmptyFile("No Preview Available"),
    );
  }

  Widget buildEmptyFile(String text) => Container(
        decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: new BorderRadius.all(
              const Radius.circular(20.0),
            )),
        width: 120,
        height: 120,
        child: Center(
          child: Text(
            text,
            style: const TextStyle(color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ),
      );
}
