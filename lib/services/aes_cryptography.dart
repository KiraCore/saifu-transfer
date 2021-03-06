import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class AESCryptographyService {
  static String encryptAES(String database, String password) {
    // Create Hash of Password (Hexadecimal)
    Digest hashedPassword = sha256.convert(utf8.encode(password));

    // Create KEY used for creating AES Object, from Hexadecimal representation of Hash Password
    final Key key = Key.fromBase16(hashedPassword.toString());

    // Generate a random key initial IV ( initial initialization vector using Random Secure)
    final IV iiv = IV.fromSecureRandom(16);

    // Create Object for Encryption and Decryption using Key
    final Encrypter encrypter = Encrypter(AES(key));

    // HEX representation of random secure and hashed password combined to created Hashed IV
    final hivp = sha256.convert(iiv.bytes + hashedPassword.bytes);

    // HIVP is broken into two compontents and is using Hex-representation as formuale doesn't support bytes
    // HEX Is of size 64, while Byte is 32

    // Prefix of HIVP is used for AES encryption of data
    final List<int> prefixHivp = hivp.bytes.getRange(0, 16).toList();
    final Uint8List unit8Prefix = Uint8List.fromList(prefixHivp);
    final IV ivAES = IV(unit8Prefix);
    // Suffix of HVIP is used for fast verification of password, changed from 16 to 4
    final List<int> suffixHivp = hivp.bytes.getRange(hivp.bytes.length - 4, hivp.bytes.length).toList();

    // hivp.toString().substring(32, 64);
    // Generate IV for AES encryption of data from first component of HIVP

    // AES encrypt the data using first HIVP component
    final Encrypted encrypted = encrypter.encrypt(database, iv: ivAES);

    // Provide prefix of random IV, encrypted data and second component of HIVP
    final encryptedData = iiv.bytes + encrypted.bytes + suffixHivp;
    // Convert bytes of encrypted data into base64 string format
    return base64Encode(encryptedData);
  }

  bool verifyPassword(String encryptedData, String password) {
    // Create Hash of Password (Hexadecimal)
    Digest hashedPassword = sha256.convert(utf8.encode(password));

    // Decrypts base 64 string of encrypted data into bytes format
    final base64decode = base64Decode(encryptedData);

    // Get's prefix and suffix
    final List<int> iiv = base64decode.getRange(0, 16).toList();
    final List<int> suffixHivp = base64decode.getRange(base64decode.length - 4, base64decode.length).toList();

    // Generate HIV for password generation
    final hivp = sha256.convert(iiv + hashedPassword.bytes);
    final suffixVerification = hivp.bytes.getRange(hivp.bytes.length - 4, hivp.bytes.length).toList();

    // Converted into String, as Dart == compares memory location at depending on the type.
    // Comparing these are bytes format, returns a false.
    if (suffixHivp.toString() == suffixVerification.toString()) {
      return true;
    } else {
      return false;
    }
  }

  static String decryptAES(encryptedData, password) {
    Digest hashedPassword = sha256.convert(utf8.encode(password));
    // Decrypts base 64 string of encrypted data into bytes format
    final base64decode = base64Decode(encryptedData);

    // Retrieves the prefix bytes and encrypted data bytes
    final List<int> iiv = base64decode.getRange(0, 16).toList();
    final List<int> decryptedBytes = base64decode.getRange(16, base64decode.length - 4).toList();

    // Generates HIVP
    final hivp = sha256.convert(iiv + hashedPassword.bytes);

    final Key key = Key.fromBase16(hashedPassword.toString());
    final Encrypter encrypter = Encrypter(AES(key));

    // First compontent of HIVP is used for AES encryption of data
    final List<int> prefixHivp = hivp.bytes.getRange(0, 16).toList();
    final Uint8List unit8Prefix = Uint8List.fromList(prefixHivp);
    // Generate IV for AES encryption of data from first component of HIVP
    final IV ivAES = IV(unit8Prefix);
    final String decryptedData = encrypter.decrypt64(base64.encode(decryptedBytes), iv: ivAES);
    return decryptedData;
  }
}
