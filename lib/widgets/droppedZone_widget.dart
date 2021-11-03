import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:saifu_air/modal/dropped_file.dart';

class DropzoneWidget extends StatefulWidget {
  final ValueChanged<DroppedFile> onDroppedFIle;
  final ValueChanged<DropzoneViewController> onDroppedDropzoneViewController;

  DropzoneWidget({Key key, this.onDroppedFIle, this.onDroppedDropzoneViewController}) : super(key: key);

  @override
  _DropzoneWidgetState createState() => _DropzoneWidgetState();
}

class _DropzoneWidgetState extends State<DropzoneWidget> {
  DropzoneViewController controller;
  bool highlighted1 = false;
  String message1 = 'drop something here';

  Future acceptFile(dynamic event) async {
    final name = event.name;
    final type = await controller.getFileMIME(event);
    final bytes = await controller.getFileSize(event);
    final url = await controller.createFileUrl(event);

    final droppedFIle = DroppedFile(url: url, name: name, mime: type.split('/')[1], bytes: bytes, event: event);

    widget.onDroppedFIle(droppedFIle);
    widget.onDroppedDropzoneViewController(controller);

    setState(() => highlighted1 = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: highlighted1
            ? null
            : LinearGradient(
                colors: [
                  Color.fromRGBO(52, 74, 230, 1),
                  Color.fromRGBO(52, 74, 230, 1),
                  Color.fromRGBO(41, 141, 255, 1),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
        color: Color.fromRGBO(41, 141, 255, 0.5),
        //color: highlighted1 ? Colors.green : Colors.red,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 100, maxHeight: 100),
            child: DropzoneView(
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
                onDrop: (ev) {
                  setState(() {
                    acceptFile(ev);
                  });
                }),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MaterialButton(
                    onPressed: () async {
                      final events = await controller.pickFiles();
                      if (events.isEmpty) return;
                      acceptFile(events.first);
                    },
                    color: Colors.white,
                    textColor: Colors.white,
                    child: Icon(
                      Icons.upload_rounded,
                      size: 24,
                      color: Colors.black,
                    ),
                    padding: EdgeInsets.all(16),
                    shape: CircleBorder(),
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    "Choose your files or drag it here",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
