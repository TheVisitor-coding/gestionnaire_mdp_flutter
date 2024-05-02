class Data {
  Map<String, List<Map<String, dynamic>>> data = {
    "data": [
      {
        "service": "Netflix",
        "id_identifiers": 1,
        "userInfo": {"identifier": "test@free.fr", "password": "Test1998"}
      }
    ]
  };
  void addData(Map<String, dynamic> content) {
    data["data"]!.add(content);
  }

  void removeData(int id) {
    data['data']!.removeWhere((element) => element['id_identifiers'] == id);
  }

  int getCurrentId() {
    if (data['data']!.isEmpty) {
      return 1;
    } else {
      return data['data']!.last['id_identifiers'] + 1;
    }
  }
}
