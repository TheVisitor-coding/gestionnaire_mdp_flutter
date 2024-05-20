import 'dart:io';
import 'dart:convert';

class FileActions {
  var file = File("./data.json");

  void writeOnFile(content) {
    if (!file.existsSync()) {
      file.createSync();
    }
    file.writeAsString(jsonEncode(content).toString());
  }
}
