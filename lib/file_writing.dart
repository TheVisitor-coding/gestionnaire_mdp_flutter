import 'dart:io';
import 'dart:convert';
import 'password_manager.dart';

class FileActions {
  var file = File("./data.json");

  void writeOnFile(content) async {
    if (!file.existsSync()) {
      file.createSync();
    }
    final jsonData = jsonEncode(content);
    final cryptedData = await PasswordManager().encryptData(jsonData);
    await file.writeAsString(jsonEncode(cryptedData).toString());
    final decryptedData = await PasswordManager().decryptData(cryptedData);
    print("Données décryptées : $decryptedData");
  }
}
