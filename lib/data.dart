import 'dart:io';
import 'dart:convert';
import 'package:gestionnaire_mdp/password_manager.dart';

import 'file_writing.dart';

class Data {
  var file = File("./data.json");
  var fileActions = FileActions();
  dynamic data;

  /// Constructeur de la classe Data
  Data() : data = {"data": []};

  /// Fonction pour initialiser le fichier data.json
  /// [return] : lecture des données du fichier data.json si le fichier existe
  Future<void> initialize() async {
    if (file.existsSync()) {
      if (file.readAsStringSync() != "") {
        data = await readData();
      } else {
        data = {"data": []};
      }
    } else {
      data = {"data": []};
    }
  }

  /// Fonction pour lire les données du fichier data.json
  /// [return] : données du fichier data.json
  Future readData() async {
    final _data = await file.readAsString();
    final decryptedData =
        await PasswordManager().decryptData(jsonDecode(_data));
    data = jsonDecode(decryptedData);
    return data;
  }

  /// Fonction pour ajouter des données dans le fichier data.json
  /// [content] : contenu à ajouter dans le fichier
  void addData(Map<String, dynamic> content) {
    data["data"]!.add(content);
    fileActions.writeOnFile(data);
  }

  /// Fonction pour supprimer des données dans le fichier data.json
  /// [id] : identifiant de la donnée à supprimer
  void removeData(int id) {
    var localData = data['data'];
    localData!.removeWhere((element) => element['id_identifiers'] == id);
    fileActions.writeOnFile(localData);
  }

  /// Fonction pour attribuer un identifiant unique à une donnée
  int getCurrentId() {
    if (data['data']!.isEmpty) {
      return 1;
    } else {
      return data['data']!.last['id_identifiers'] + 1;
    }
  }
}
