import 'dart:io';
import 'dart:convert';
import 'file_writing.dart';

class Data {
  var file = File("./data.json");
  var fileActions = FileActions();
  dynamic data;

  Data() : data = {"data": []} {
    if (file.existsSync()) {
      if (file.readAsStringSync() != "") {
        data = jsonDecode(file.readAsStringSync());
      } else {
        data = {"data": []};
      }
    } else {
      data = {"data": []};
    }
  }

  void addData(Map<String, dynamic> content) {
    data["data"]!.add(content);
    fileActions.writeOnFile(data);
  }

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
