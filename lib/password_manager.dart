import 'dart:convert';
import 'dart:io';
import 'package:cryptography/cryptography.dart';
import 'dart:typed_data';

class PasswordManager {
  static const String _dataFile = 'data.txt';
  static const int _pbkdf2Iterations = 100000;

  static SecretKey? _masterKey;

  final Pbkdf2 pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: _pbkdf2Iterations,
    bits: 256,
  );

  Future<void> setMasterPassword(String password) async {
    final secretKey = SecretKey(utf8.encode(password));
    final nonce = List<int>.generate(16, (i) => i);

    final newSecretKey = await pbkdf2.deriveKey(
      secretKey: secretKey,
      nonce: nonce,
    );

    _masterKey = newSecretKey;

    final hash = await newSecretKey.extractBytes();
    final hashString = base64.encode(nonce + hash);

    final file = File(_dataFile);
    await file.writeAsString(hashString);
  }

  Future<bool> verifyMasterPassword(String password) async {
    final file = File(_dataFile);
    if (!await file.exists()) return false;

    final storedHashString = await file.readAsString();
    final storedHash = base64.decode(storedHashString);

    final nonce = storedHash.sublist(0, 16);
    final storedKey = storedHash.sublist(16);

    final secretKey = SecretKey(utf8.encode(password));
    final newSecretKey = await pbkdf2.deriveKey(
      secretKey: secretKey,
      nonce: nonce,
    );

    final newKey = await newSecretKey.extractBytes();

    _masterKey = newSecretKey;

    return _compareLists(storedKey, newKey);
  }

  Future<bool> masterPasswordExists() async {
    final file = File(_dataFile);
    return await file.exists();
  }

  bool _compareLists(List<int> list1, List<int> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  Future<String> encryptData(String data) async {
    if (_masterKey == null) {
      throw Exception('Master password not set');
    }
    final algorithm = AesGcm.with256bits();
    final nonce = algorithm.newNonce();

    final encrypted = await algorithm.encrypt(
      utf8.encode(data),
      secretKey: _masterKey!,
      nonce: nonce,
    );

    final combined = nonce + encrypted.cipherText + encrypted.mac.bytes;
    return base64.encode(Uint8List.fromList(combined));
  }

  Future<String> decryptData(String data) async {
    if (_masterKey == null) {
      throw Exception('Master password not set');
    }
    final algorithm = AesGcm.with256bits();
    final decoded = base64.decode(data);

    final nonce = decoded.sublist(0, 12);
    final cipherText = decoded.sublist(12, decoded.length - 16);
    final mac = Mac(decoded.sublist(decoded.length - 16));

    final secretBox = SecretBox(
      cipherText,
      nonce: nonce,
      mac: mac,
    );

    final decrypted = await algorithm.decrypt(
      secretBox,
      secretKey: _masterKey!,
    );

    return utf8.decode(decrypted);
  }
}
