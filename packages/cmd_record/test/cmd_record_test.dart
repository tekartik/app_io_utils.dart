@TestOn('vm')
library;

import 'package:dev_test/test.dart';
import 'package:path/path.dart';
import 'package:process_run/cmd_run.dart';
import 'package:tekartik_cmd_record/src/cmd_record.dart';
import 'package:tekartik_cmd_record/src/import.dart';

String get cmdRecordScriptPath => join('bin', 'cmd_record.dart');

String get echoScriptPath => join('example', 'echo.dart');

void main() {
  group('cmd_record', () {
    test('version', () async {
      final result = await runCmd(DartCmd([cmdRecordScriptPath, '--version']));
      expect(result.stderr.toString().toLowerCase(), contains('version'));
      // 'Dart VM version: 1.7.0-dev.4.5 (Thu Oct  9 01:44:31 2014) on 'linux_x64'\n'
    });

    test('out', () async {
      final history = History();
      ProcessCmd cmd = DartCmd([echoScriptPath, '--stdout', 'out']);
      await record(cmd.executable, cmd.arguments,
          noStdOutput: true, history: history);
      //devPrint(JSON.encode(history));
      expect(history.outItems.first.line, 'out');
    });

    test('err', () async {
      final history = History();
      ProcessCmd cmd = DartCmd([echoScriptPath, '--stderr', 'err']);
      await record(cmd.executable, cmd.arguments,
          noStdOutput: true, history: history);
      //devPrint(JSON.encode(history));
      expect(history.errItems.first.line, 'err');
    }, onPlatform: {'windows': const Skip('failing')});

    test('in', () async {
      final history = History();
      ProcessCmd cmd = DartCmd([echoScriptPath, '--stdin']);
      var inController = StreamController<List<int>>();
      final future = record(cmd.executable, cmd.arguments,
          noStdOutput: true, inStream: inController.stream, history: history);
      inController.add(utf8.encode('in'));
      await inController.close();
      await future;
      //devPrint(JSON.encode(history));
      expect(history.inItems.first.line, 'in');
    });
  });
}
