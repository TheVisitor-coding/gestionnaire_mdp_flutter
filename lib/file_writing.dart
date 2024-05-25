import 'dart:io';
import 'dart:convert';
import 'password_manager.dart';

class FileActions {
  var file = File("./data.json");

  /// Fonction pour écrire dans un fichier les données cryptées
  /// [content] : contenu à écrire dans le fichier
  /// [return] : écriture des données cryptées dans le fichier data.json
  void writeOnFile(content) async {
    if (!file.existsSync()) {
      file.createSync();
    }
    final jsonData = jsonEncode(content);
    final cryptedData = await PasswordManager().encryptData(jsonData);
    await file.writeAsString(jsonEncode(cryptedData).toString());
  }
}
