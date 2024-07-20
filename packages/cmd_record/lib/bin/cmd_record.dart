#!/usr/bin/env dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:tekartik_cmd_record/src/cmd_record.dart';

Version _version = Version(0, 1, 0);

String get _currentScriptName => basenameWithoutExtension(Platform.script.path);

/*
Testing

bin/cmd_record.dart example/echo.dart --stdout out
bin/cmd_record.dart -v -i cat

Global options:
-h, --help          Usage help
-o, --stdout        stdout content as string
-p, --stdout-hex    stdout as hexa string
-e, --stderr        stderr content as string
-f, --stderr-hex    stderr as hexa string
-i, --stdin         Handle first line of stdin
-x, --exit-code     Exit code to return
    --version       Print the command version
*/

const String _flagRunInShell = 'run-in-shell';
const String _flagStdin = 'stdin';
const String _flagOwnStdin = 'own-stdin';
const String _flagJson = 'json';
const String _flagNoStderr = 'no-stderr';

///
/// write rest arguments as lines
///
Future main(List<String> arguments) async {
  //setupQuickLogging();

  final parser = ArgParser(allowTrailingOptions: false);
  parser.addFlag('help', abbr: 'h', help: 'Usage help', negatable: false);
  parser.addFlag('verbose', abbr: 'v', help: 'Verbose', negatable: false);
  parser.addFlag(_flagNoStderr, abbr: 'n', help: 'No stderr', negatable: false);
  parser.addFlag(_flagRunInShell,
      abbr: 's', help: 'RunInShell', negatable: false);
  parser.addFlag(_flagJson, abbr: 'j', help: 'Save as json', negatable: false);
  parser.addFlag(_flagStdin,
      abbr: 'i',
      help: 'stdin read, need CTRL-C to terminate',
      defaultsTo: false,
      negatable: true);
  parser.addFlag(_flagOwnStdin,
      abbr: 'w',
      help: 'handle stdin and forward command',
      defaultsTo: false,
      negatable: true);
  parser.addOption('exit-code', abbr: 'x', help: 'Exit code to return');
  parser.addFlag('version',
      help: 'Print the command version', negatable: false);

  final argResults = parser.parse(arguments);

  final help = argResults['help'] as bool;
  final verbose = argResults['verbose'] as bool?;
  final runInShell = argResults[_flagRunInShell] as bool?;
  final recordStdin = argResults[_flagStdin] as bool?;
  final asJson = argResults[_flagJson] as bool?;
  final noStdErr = argResults[_flagNoStderr] as bool?;
  final ownStdin = argResults[_flagOwnStdin] as bool?;

  void printUsage() {
    stdout.writeln('Echo utility');
    stdout.writeln();
    stdout.writeln('Usage: $_currentScriptName <command> [<arguments>]');
    stdout.writeln();
    stdout.writeln("Example: $_currentScriptName -o 'Hello world'");
    stdout.writeln("will display 'Hello world'");
    stdout.writeln();
    stdout.writeln('Global options:');
    stdout.writeln(parser.usage);
  }

  if (help) {
    printUsage();
    return;
  }

  final displayVersion = argResults['version'] as bool;

  if (displayVersion) {
    stderr.writeln('$_currentScriptName version $_version');
    stderr.writeln('VM: ${Platform.resolvedExecutable} ${Platform.version}');
    return;
  }

  if (argResults.rest.isEmpty) {
    stderr.writeln('Need a command');
    exit(1);
  }

  // first agument is executable, remaining is arguments
  final cmdExecutable = argResults.rest.first;
  final cmdArguments = argResults.rest.sublist(1);

  History? history;
  IOSink? ioSink;
  if (asJson! || verbose!) {
    history = History();
  } else {
    ioSink = File('cmd_record.log').openWrite(mode: FileMode.write);
  }

  Stream<List<int>>? inStream;
  late StreamController<List<int>> inStreamController;
  if (ownStdin!) {
    inStreamController = StreamController<List<int>>(sync: true);
    inStream = inStreamController.stream;
    stdin
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((String line) {
      inStreamController.add(utf8.encode('$line\n'));
    });
  }

  await record(cmdExecutable, cmdArguments,
      runInShell: runInShell,
      recordStdin: recordStdin,
      history: history,
      dumpSink: ioSink,
      noStderr: noStdErr,
      inStream: inStream);

  if (ownStdin) {
    await inStreamController.close();
  }
  if (verbose!) {
    dump(history!);
  }

  if (history != null) {
    await File('cmd_record.json').writeAsString(json.encode(history));
  }
}
