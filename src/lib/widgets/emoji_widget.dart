import 'package:flutter/material.dart';
import 'package:saifu_transfer/services/checksum_emojis.dart';

class EmojiWidget extends StatefulWidget {
  const EmojiWidget({
    Key key,
    this.checksum,
  }) : super(key: key);

  final String checksum;

  @override
  State<EmojiWidget> createState() => _EmojiWidgetState();
}

class _EmojiWidgetState extends State<EmojiWidget> {
  bool expandedTile = false;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: EmojiCheckSum.convertToEmoji(widget.checksum),
        builder: (context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black));
            default:
              if ((snapshot.hasError)) {
                return const Center(child: Text("Issue related to EmojiSum"));
              } else {
                return InkWell(
                  onTap: () {
                    setState(() {
                      expandedTile = !expandedTile;
                    });
                  },
                  child: Row(
                    children: [
                      expandedTile
                          ? Container(
                              constraints: const BoxConstraints(maxWidth: 350),
                              child: Text(
                                "SHA256: " + snapshot.data[0],
                                style: const TextStyle(fontSize: 15, color: Colors.black),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : Container(
                              constraints: const BoxConstraints(maxWidth: 350),
                              child: Text(
                                snapshot.data[1],
                                style: const TextStyle(fontSize: 20, color: Colors.black),
                                textAlign: TextAlign.center,
                              ),
                            ),
                      expandedTile ? const Icon(Icons.keyboard_arrow_up_rounded) : const Icon(Icons.keyboard_arrow_down_rounded)
                    ],
                  ),
                );
              }
          }
        });
  }
}
