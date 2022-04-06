// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saifu_transfer/screens/receive_file.dart';
import 'package:saifu_transfer/widgets/qr_code_file_transfer.dart';

class RecieveButton extends StatelessWidget {
  const RecieveButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Colors.grey[100],
      ),
      height: 150,
      child: TextButton(
        style: ButtonStyle(
          overlayColor: MaterialStateProperty.all(Colors.grey[50]),
        ),
        onPressed: () async {
          var data = await showDialog(barrierDismissible: false, barrierColor: Colors.transparent, context: context, builder: (_) => QrCodeFileTransfer());
          if (data == false) return;
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => ReceiveFile(
                        qrData: data[0],
                        encrypted: data[1],
                      )));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.file_download_outlined,
              color: Colors.black,
              size: 40,
            ),
            Text(
              "Receive a file",
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
