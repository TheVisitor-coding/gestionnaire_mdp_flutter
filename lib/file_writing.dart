import 'dart:io';
import 'dart:convert';

class FileActions {
  var file = File("./data.json");

  void writeOnFile(content) {
    file.writeAsString(jsonEncode(content).toString());
  }
}
