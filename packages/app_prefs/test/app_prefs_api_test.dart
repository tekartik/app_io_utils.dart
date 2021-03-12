import 'package:test/test.dart';
import 'package:tekartik_app_io_prefs/app_prefs.dart';

void main() async {
  group('getPrefsFactory', () {
    test('def', () {
      // ignore: unnecessary_statements
      Prefs;
      // ignore: unnecessary_statements
      PrefsFactory;
      // ignore: unnecessary_statements
      getPrefsFactory;
      prefsFactory;
      prefsFactoryMemory;
      print(prefsFactory.runtimeType);
    });
  });
}
