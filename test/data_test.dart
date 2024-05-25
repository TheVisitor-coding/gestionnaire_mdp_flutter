import 'package:test/test.dart';
import 'package:gestionnaire_mdp/data.dart';

void main() {
  group('Function getCurrentId', () {
    test('get current id if data is empty', () {
      var data = Data();
      data.data = {"data": []};
      expect(data.getCurrentId(), 1);
    });

    test('get current id if data is not empty', () {
      var data = Data();
      data.data = {
        "data": [
          {"id_identifiers": 1}
        ]
      };
      expect(data.getCurrentId(), 2);
    });
  });
}
