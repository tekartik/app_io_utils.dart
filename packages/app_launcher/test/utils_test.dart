import 'dart:io';

import 'package:tekartik_app_io_launcher/src/utils.dart';
import 'package:test/test.dart';

void main() {
  test('parse', () {
    var uri = pathToUriDefaultToFile('my_file');
    expect(uri.toString(), 'my_file');
    if (!Platform.isWindows) {
      uri = pathToUriDefaultToFile('/my_file');
      expect(uri.toString(), 'file:///my_file');
    }
    expect(
        pathToUriDefaultToFile('http://my_file').toString(), 'http://my_file');
    expect(pathToUriDefaultToFile('git@github.com:tekartik/git').toString(),
        'git@github.com:tekartik/git');
  });
}
