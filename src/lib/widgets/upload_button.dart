import 'dart:developer';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:saifu_air/file_model.dart';
import 'package:saifu_air/screens/upload_file.dart';

class UploadButton extends StatefulWidget {
  const UploadButton({
    Key key,
  }) : super(key: key);

  @override
  State<UploadButton> createState() => _UploadButtonState();
}

class _UploadButtonState extends State<UploadButton> {
  DropzoneViewController controller;
  bool dropZoneHover = false;
  bool fileUploaded = false;
  FileInformation file;
  bool loading = false;

  Future uploadedFileProcess(dynamic event) async {
    setState(() {
      loading = true;
    });
    try {
      final name = event.name;
      final type = await controller.getFileMIME(event);
      final bytes = await controller.getFileSize(event);
      final url = await controller.createFileUrl(event);
      var fileData = await controller.getFileData(event);
      file = FileInformation(url: url, name: name, mime: type.split('/')[1], bytes: bytes, data: fileData);
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => UploadedFile(
                    file: file,
                  )));
      setState(() {
        dropZoneHover = false;
        loading = false;
      });
    } catch (e) {
      log(e);
      setState(() {
        dropZoneHover = false;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      color: dropZoneHover ? Colors.blue : Colors.grey,
      dashPattern: const [7, 7],
      borderType: BorderType.RRect,
      strokeCap: StrokeCap.round,
      strokeWidth: 1,
      radius: const Radius.circular(20),
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: dropZoneHover ? Colors.grey[50] : Colors.grey.shade100,
        ),
        child: Stack(
          children: [
            DropzoneView(
              operation: DragOperation.copy,
              cursor: CursorType.grab,
              onCreated: (ctrl) => controller = ctrl,
              onHover: () {
                setState(() => dropZoneHover = true);
              },
              onLeave: () {
                setState(() => dropZoneHover = false);
              },
              onDrop: (event) async {
                uploadedFileProcess(event);
              },
            ),
            loading
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black)))],
                  )
                : Positioned.fill(
                    child: TextButton(
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.all(Colors.grey[50]),
                      ),
                      onPressed: () async {
                        final events = await controller.pickFiles();
                        if (events.isEmpty) return;
                        uploadedFileProcess(events.first);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.file_upload_outlined,
                            color: Colors.black,
                            size: 40,
                          ),
                          Text(
                            "Drop or upload\na file",
                            style: TextStyle(color: Colors.black, fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
