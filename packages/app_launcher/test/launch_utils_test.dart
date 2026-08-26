@TestOn('vm')
library;

import 'dart:io';

import 'package:path/path.dart';
import 'package:tekartik_app_io_launcher/src/launch_utils.dart';
import 'package:test/test.dart';

void main() {
  group('whichFirst', () {
    test('found', () async {
      var command = Platform.isWindows ? 'cmd' : 'ls';
      expect(await whichFirst(['dummy_no_such_command', command]), isNotNull);
    });
    test('not found', () async {
      expect(await whichFirst(['dummy_no_such_command']), isNull);
      expect(await whichFirst([]), isNull);
    });
  });

  group('startDetached', () {
    test('starts', () async {
      var dir = await Directory.systemTemp.createTemp('launch_utils_test');
      try {
        var path = join(dir.path, 'created by the detached process.txt');
        // A path with spaces must not need any quoting.
        var started = Platform.isWindows
            ? await startDetached('cmd', ['/c', 'echo ok>$path'])
            : await startDetached('sh', ['-c', 'echo ok > "\$1"', 'sh', path]);
        expect(started, isTrue);
        // Detached, so wait for the file to show up.
        var file = File(path);
        for (var i = 0; i < 50 && !file.existsSync(); i++) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
        expect((await file.readAsString()).trim(), 'ok');
      } finally {
        await dir.delete(recursive: true);
      }
    });
    test('missing executable', () async {
      expect(await startDetached('dummy_no_such_command', []), isFalse);
    });
    test('missing working directory', () async {
      var command = Platform.isWindows ? 'cmd' : 'ls';
      expect(
        await startDetached(
          command,
          [],
          workingDirectory: join('dummy', 'no', 'such', 'dir'),
        ),
        isFalse,
      );
    });
  });
}
