import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saifu_air/services/aes_services.dart';
import 'package:saifu_air/services/random_password.dart';

// ignore: must_be_immutable
class SecureDialog extends StatefulWidget {
  String data;
  bool encrypted = false;
  SecureDialog(this.data, this.encrypted);
  @override
  State<SecureDialog> createState() => _SecureDialogState();
}

class _SecureDialogState extends State<SecureDialog> {
  TextEditingController passwordText = TextEditingController();
  TextEditingController specifyPasswordLength = TextEditingController();
  final password = RandomPasswordGenerator();
  String specifiedLength = '9';
  bool _isWithLetters = true;
  bool _isWithUppercase = true;
  bool _isWithNumbers = true;
  bool _isWithSpecial = true;
  bool _customTileExpanded = false;
  String isOk = '';
  Color _color = Colors.blue;

  @override
  Widget build(BuildContext context) {
    specifyPasswordLength.text = specifiedLength;
    checkBox(String name, Function onTap, bool value) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(name),
          Checkbox(
            value: value,
            onChanged: onTap,
            checkColor: Colors.black,
            fillColor: MaterialStateProperty.all(Colors.grey[300]),
          ),
        ],
      );
    }

    return AlertDialog(
      elevation: 50,
      shape: RoundedRectangleBorder(side: BorderSide(color: Colors.white, width: 5), borderRadius: BorderRadius.all(Radius.circular(32.0))),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TextButton.icon(
                  style: ButtonStyle(
                    overlayColor: MaterialStateColor.resolveWith((states) => Colors.white),
                  ),
                  onPressed: () => Navigator.pop(context, false),
                  icon: Icon(
                    Icons.navigate_before,
                    color: Colors.black,
                  ),
                  label: Text(
                    "Back",
                    style: TextStyle(color: Colors.black),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: Column(
                children: [
                  Text('Please enter the passphrase'),
                  IntrinsicWidth(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                          child: SizedBox(
                            width: 300,
                            child: TextField(
                              controller: passwordText,
                              onChanged: (value) {
                                double passwordstrength = password.checkPassword(password: value);
                                if (passwordstrength < 0.3) {
                                  _color = Colors.red;
                                  isOk = 'Password is weak!';
                                } else if (passwordstrength < 0.7) {
                                  _color = Colors.blue;
                                  isOk = 'Password is Good';
                                } else {
                                  _color = Colors.green;
                                  isOk = 'Password is Strong';
                                }
                                setState(() {});
                              },
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                  borderSide: BorderSide(width: 1, color: Colors.black),
                                ),
                                border: OutlineInputBorder(borderSide: new BorderSide(color: Colors.amberAccent)),
                              ),
                            ),
                          ),
                        ),
                        if (passwordText.text.isNotEmpty && passwordText.text != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              isOk,
                              style: TextStyle(color: _color, fontSize: 14),
                            ),
                          ),
                        Visibility(
                          visible: !widget.encrypted,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Theme(
                              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                title: const Text(
                                  'Generate Password',
                                  style: TextStyle(color: Colors.black),
                                ),
                                //subtitle: const Text('Custom expansion arrow icon'),
                                trailing: Icon(
                                  _customTileExpanded ? Icons.arrow_drop_down_circle : Icons.arrow_drop_down,
                                  color: Colors.black,
                                ),
                                children: <Widget>[
                                  Row(
                                    children: [
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Wrap(
                                                direction: Axis.horizontal,
                                                children: [
                                                  Column(
                                                    children: [
                                                      checkBox('Upper Case', (bool value) {
                                                        _isWithUppercase = value;
                                                        setState(() {});
                                                      }, _isWithUppercase),
                                                      checkBox('Lower Case', (bool value) {
                                                        _isWithLetters = value;
                                                        setState(() {});
                                                      }, _isWithLetters),
                                                    ],
                                                  ),
                                                  Column(
                                                    children: [
                                                      checkBox('Symbols', (bool value) {
                                                        _isWithSpecial = value;
                                                        setState(() {});
                                                      }, _isWithSpecial),
                                                      checkBox('Numbers', (bool value) {
                                                        _isWithNumbers = value;
                                                        setState(() {});
                                                      }, _isWithNumbers),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                                                child: SizedBox(
                                                  width: 50,
                                                  child: TextField(
                                                    controller: specifyPasswordLength,
                                                    keyboardType: TextInputType.number,
                                                    inputFormatters: <TextInputFormatter>[
                                                      // FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                                      FilteringTextInputFormatter.digitsOnly
                                                    ],
                                                    decoration: const InputDecoration(
                                                      focusedBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.all(Radius.circular(4)),
                                                        borderSide: BorderSide(width: 1, color: Colors.black),
                                                      ),
                                                      border: OutlineInputBorder(borderSide: BorderSide(color: Colors.amberAccent)),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      TextButton(
                                          style: TextButton.styleFrom(
                                            primary: Colors.grey,
                                          ),
                                          onPressed: () {
                                            String newPassword = password.randomPassword(letters: _isWithLetters, numbers: _isWithNumbers, passwordLength: double.parse(specifyPasswordLength.text), specialChar: _isWithSpecial, uppercase: _isWithUppercase);
                                            passwordText.text = newPassword;
                                            double passwordstrength = password.checkPassword(password: newPassword);
                                            if (passwordstrength < 0.3) {
                                              _color = Colors.red;
                                              isOk = 'Password is weak!';
                                            } else if (passwordstrength < 0.7) {
                                              _color = Colors.blue;
                                              isOk = 'Password is Good';
                                            } else {
                                              _color = Colors.green;
                                              isOk = 'Passsword is Strong';
                                            }
                                            setState(() {
                                              specifiedLength = specifyPasswordLength.text;
                                            });
                                          },
                                          child: const Icon(
                                            Icons.autorenew_rounded,
                                            color: Colors.black,
                                          )),
                                    ],
                                  ),
                                ],
                                onExpansionChanged: (bool expanded) {
                                  setState(() => _customTileExpanded = expanded);
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          icon: Icon(
                            Icons.close_rounded,
                            color: Colors.red,
                          )),
                      IconButton(
                          onPressed: () {
                            if (widget.encrypted) {
                              try {
                                String data = AESCryptographyService().decryptAES(widget.data, passwordText.text);
                                Navigator.pop(context, data);
                              } catch (e) {
                                print("AES Decryption failed: $e");
                              }
                            } else {
                              try {
                                String data = AESCryptographyService().encryptAES(widget.data, passwordText.text);
                                Navigator.pop(context, data);
                              } catch (e) {
                                print("AES Encryption failed: $e");
                              }
                            }
                          },
                          icon: Icon(
                            Icons.check_rounded,
                            color: Colors.green,
                          )),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
