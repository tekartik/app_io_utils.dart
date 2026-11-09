@TestOn('vm && linux')
library;

import 'dart:io';

import 'package:path/path.dart';
import 'package:process_run/shell.dart';
import 'package:tekartik_app_io_launcher/launcher.dart';
import 'package:test/test.dart';

void main() {
  test(
    'launchTextEdit returns without gedit (no vi without a terminal)',
    () async {
      var dir = await Directory.systemTemp.createTemp('launch_text_edit');
      addTearDown(() => dir.delete(recursive: true));
      var bin = Directory(join(dir.path, 'bin'))..createSync();
      // A vi that, like the real one without a terminal, waits for input.
      var vi = File(join(bin.path, 'vi'))
        ..writeAsStringSync('#!/bin/sh\nread line\n');
      await run('chmod +x ${shellArgument(vi.path)}', verbose: false);

      // Only that vi on the path: no gedit.
      shellEnvironment = ShellEnvironment.empty()..paths.add(bin.path);
      addTearDown(() => shellEnvironment = null);

      var file = join(dir.path, 'file.txt');
      expect(
        await launchTextEdit(file).timeout(const Duration(seconds: 10)),
        isFalse,
      );
      // Created anyway (doNotCreate is false).
      expect(File(file).existsSync(), isTrue);
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );
}
