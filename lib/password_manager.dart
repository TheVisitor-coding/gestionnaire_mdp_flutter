import 'dart:convert';
import 'dart:io';
import 'package:cryptography/cryptography.dart';

class PasswordManager {
  static const String _dataFile = 'data.txt';
  static const int _pbkdf2Iterations = 100000;

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
}
