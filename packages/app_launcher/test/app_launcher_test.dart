import 'package:tekartik_app_io_launcher/launcher.dart';
import 'package:test/test.dart';

void main() async {
  group('public', () {
    test('def', () {
      // ignore: unnecessary_statements
      launchChrome;
      // ignore: unnecessary_statements
      launchTextEdit;
      // ignore: unnecessary_statements
      launchFileExplorer;
    });
  });
}
