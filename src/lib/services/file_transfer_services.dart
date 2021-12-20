import 'dart:convert';

import 'package:archive/archive.dart';

class FileTransferServices {
  String generateBase64data(var fileBytes) {
    // This takes the file bytes of the original imported file
    // Gzip it, base64 encodes it
    var gzipBytes = GZipEncoder().encode(fileBytes);
    String str = base64.encode(gzipBytes);
    return str;
  }

  List<String> generateStringFrames(var qrData, var split) {
    // This takes the file bytes of the original imported file
    // Gzip it, base64 encodes it and split it equal outcome, before returning it as a list
    // Generates checksum and Frames for it
    RegExp frames = RegExp(".{1," + split.toStringAsFixed(0) + "}");
    Iterable<Match> matches = frames.allMatches(qrData);
    List<String> list = matches.map((m) => m.group(0)).toList();
    return list;
  }
}
