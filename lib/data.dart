import 'dart:io';
import 'dart:convert';
import 'package:gestionnaire_mdp/password_manager.dart';

import 'file_writing.dart';

class Data {
  var file = File("./data.json");
  var fileActions = FileActions();
  dynamic data;

  /// Fonction pour lire les données du fichier data.json
  /// SI le fichier existe
  /// [data] : données du fichier data.json
  /// [return] : données du fichier data.json
  // Data() : data = {"data": []} {
  //   if (file.existsSync()) {
  //     if (file.readAsStringSync() != "") {
  //       data = readData();
  //       print("Fichier non vide");
  //     } else {
  //       data = {"data": []};
  //       data = readData();
  //       print("Fichier vide");
  //     }
  //   } else {
  //     data = {"data": []};
  //     data = readData();
  //     print("Fichier inexistant");
  //   }
  // }

  Data() : data = {"data": []};

  Future<void> initialize() async {
    if (file.existsSync()) {
      if (file.readAsStringSync() != "") {
        data = await readData();
        print("data instancié" + data.toString());
        print("Fichier non vide");
      } else {
        data = {"data": []};
        print("Fichier vide");
      }
    } else {
      data = {"data": []};
      print("Fichier inexistant");
    }
  }

  Future readData() async {
    final _data = await file.readAsString();
    print("Données cryptées : $_data");
    final decryptedData =
        await PasswordManager().decryptData(jsonDecode(_data));
    print("Données décryptées : $decryptedData");
    data = jsonDecode(decryptedData);
    return data;
  }

  /// Fonction pour ajouter des données dans le fichier data.json
  void addData(Map<String, dynamic> content) {
    print("Ajout de données : $content");
    print("Données actuelles : $data");
    data["data"]!.add(content);
    fileActions.writeOnFile(data);
    print("Données ajoutées : $data");
  }

  /// Fonction pour supprimer des données dans le fichier data.json
  void removeData(int id) {
    var localData = data['data'];
    localData!.removeWhere((element) => element['id_identifiers'] == id);
    fileActions.writeOnFile(localData);
  }

  int getCurrentId() {
    if (data['data']!.isEmpty) {
      return 1;
    } else {
      return data['data']!.last['id_identifiers'] + 1;
    }
  }
}
