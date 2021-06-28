import 'package:tekartik_app_io_sembast/sembast.dart';
import 'package:test/test.dart';

Future main() async {
  var factory = getDatabaseFactory(
      packageName: 'tekartik_app_sembast_io_test.tekartik.com');

  group('sembast', () {
    test('factory', () async {
      expect(await factory.openDatabase('test.db'), isNotNull);
    });
  });
}
