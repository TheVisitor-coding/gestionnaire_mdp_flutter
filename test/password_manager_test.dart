import 'package:test/test.dart';
import 'package:gestionnaire_mdp/password_manager.dart';

void main() {
  group('Compare list of passwords', () {
    test('Comparaison de deux listes identiques', () {
      final list1 = [1, 2, 3];
      final list2 = [1, 2, 3];
      expect(PasswordManager.compareLists(list1, list2), true);
    });

    test('Comparaison de deux listes différentes', () {
      final list1 = [1, 2, 3];
      final list2 = [1, 2, 4];
      expect(PasswordManager.compareLists(list1, list2), false);
    });
  });
}
