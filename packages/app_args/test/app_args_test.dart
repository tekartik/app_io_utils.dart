import 'package:tekartik_app_args/app_args.dart';
import 'package:test/test.dart';

void main() {
  group('args', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('flag', () {
      print('test');
      expect(flagHelp.name, 'help');
    });
  });
}
