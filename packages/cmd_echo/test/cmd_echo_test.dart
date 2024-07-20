@TestOn('vm')
library;

import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:process_run/process_run.dart';
import 'package:test/test.dart';

String get echoScriptPath => join('bin', 'echo.dart');

void main() {
  group('cmd_echo', () {
    Future runCheck(
      void Function(ProcessResult result) check,
      String executable,
      List<String> arguments, {
      String? workingDirectory,
      Map<String, String>? environment,
      bool includeParentEnvironment = true,
      bool runInShell = false,
      SystemEncoding? stdoutEncoding = systemEncoding,
      SystemEncoding? stderrEncoding = systemEncoding,
      StreamSink<List<int>>? stdout,
    }) async {
      var result = await Process.run(
        executable,
        arguments,
        workingDirectory: workingDirectory,
        environment: environment,
        includeParentEnvironment: includeParentEnvironment,
        runInShell: runInShell,
        stdoutEncoding: stdoutEncoding,
        stderrEncoding: stderrEncoding,
      );
      check(result);
      result = await runExecutableArguments(executable, arguments,
          workingDirectory: workingDirectory,
          environment: environment,
          includeParentEnvironment: includeParentEnvironment,
          runInShell: runInShell,
          stdoutEncoding: stdoutEncoding,
          stderrEncoding: stderrEncoding,
          stdout: stdout);
      check(result);
    }

    test('stdout', () async {
      void checkOut(ProcessResult result) {
        expect(result.stderr, '');
        expect(result.stdout, 'out');
        expect(result.pid, isNotNull);
        expect(result.exitCode, 0);
      }

      void checkEmpty(ProcessResult result) {
        expect(result.stderr, '');
        expect(result.stdout, '');
        expect(result.pid, isNotNull);
        expect(result.exitCode, 0);
      }

      await runCheck(
          checkOut, dartExecutable!, [echoScriptPath, '--stdout', 'out']);
      await runCheck(checkEmpty, dartExecutable!, [echoScriptPath]);
    });

    test('stdout_bin', () async {
      void check123(ProcessResult result) {
        expect(result.stderr, '');
        expect(result.stdout, [1, 2, 3]);
        expect(result.pid, isNotNull);
        expect(result.exitCode, 0);
      }

      void checkEmpty(ProcessResult result) {
        expect(result.stderr, '');
        expect(result.stdout, isEmpty);
        expect(result.pid, isNotNull);
        expect(result.exitCode, 0);
      }

      await runCheck(
          check123, dartExecutable!, [echoScriptPath, '--stdout-hex', '010203'],
          stdoutEncoding: null);
      await runCheck(checkEmpty, dartExecutable!, [echoScriptPath],
          stdoutEncoding: null);
    });

    test('stderr', () async {
      void checkErr(ProcessResult result) {
        expect(result.stdout, '');
        expect(result.stderr, 'err');
        expect(result.pid, isNotNull);
        expect(result.exitCode, 0);
      }

      void checkEmpty(ProcessResult result) {
        expect(result.stderr, '');
        expect(result.stdout, '');
        expect(result.pid, isNotNull);
        expect(result.exitCode, 0);
      }

      await runCheck(
          checkErr, dartExecutable!, [echoScriptPath, '--stderr', 'err'],
          stdout: stdout);
      await runCheck(checkEmpty, dartExecutable!, [echoScriptPath]);
    });

    test('stderr_bin', () async {
      void check123(ProcessResult result) {
        expect(result.stdout, '');
        expect(result.stderr, [1, 2, 3]);
        expect(result.pid, isNotNull);
        expect(result.exitCode, 0);
      }

      void checkEmpty(ProcessResult result) {
        expect(result.stdout, '');
        expect(result.stderr, isEmpty);
        expect(result.pid, isNotNull);
        expect(result.exitCode, 0);
      }

      await runCheck(
          check123, dartExecutable!, [echoScriptPath, '--stderr-hex', '010203'],
          stderrEncoding: null);
      await runCheck(checkEmpty, dartExecutable!, [echoScriptPath],
          stderrEncoding: null);
    });

    test('exitCode', () async {
      void check123(ProcessResult result) {
        expect(result.stdout, '');
        expect(result.stderr, '');
        expect(result.pid, isNotNull);
        expect(result.exitCode, 123);
      }

      void check0(ProcessResult result) {
        expect(result.stdout, '');
        expect(result.stderr, '');
        expect(result.pid, isNotNull);
        expect(result.exitCode, 0);
      }

      await runCheck(
          check123, dartExecutable!, [echoScriptPath, '--exit-code', '123']);
      await runCheck(check0, dartExecutable!, [echoScriptPath]);
    });

    test('crash', () async {
      void check(ProcessResult result) {
        expect(result.stdout, '');
        expect(result.stderr, isNotEmpty);
        expect(result.pid, isNotNull);
        expect(result.exitCode, 255);
      }

      await runCheck(
          check, dartExecutable!, [echoScriptPath, '--exit-code', 'crash']);
    });
  });
}
