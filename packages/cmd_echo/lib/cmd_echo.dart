import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:tekartik_common_utils/hex_utils.dart';

Version version = Version(0, 1, 0);

String get currentScriptName => basenameWithoutExtension(Platform.script.path);

/*
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

///
/// write rest arguments as lines
///
Future main(List<String> arguments) async {
  //setupQuickLogging();

  final parser = ArgParser(allowTrailingOptions: false);
  parser.addFlag('help', abbr: 'h', help: 'Usage help', negatable: false);
  parser.addFlag('verbose', abbr: 'v', help: 'Verbose', negatable: false);
  parser.addOption('stdout',
      abbr: 'o', help: 'stdout content as string', defaultsTo: null);
  parser.addOption('stdout-hex',
      abbr: 'p', help: 'stdout as hexa string', defaultsTo: null);
  parser.addOption('stderr',
      abbr: 'e', help: 'stderr content as string', defaultsTo: null);
  parser.addOption('stderr-hex',
      abbr: 'f', help: 'stderr as hexa string', defaultsTo: null);
  parser.addFlag('stdin',
      abbr: 'i', help: 'Handle first line of stdin', negatable: false);
  parser.addOption('exit-code', abbr: 'x', help: 'Exit code to return');
  parser.addFlag('version',
      help: 'Print the command version', negatable: false);

  final argResults = parser.parse(arguments);

  var help = argResults['help'] as bool;
  var verbose = argResults['verbose'] as bool?;

  void printUsage() {
    stdout.writeln('Echo utility');
    stdout.writeln();
    stdout.writeln('Usage: $currentScriptName <command> [<arguments>]');
    stdout.writeln();
    stdout.writeln("Example: $currentScriptName -o 'Hello world'");
    stdout.writeln("will display 'Hello world'");
    stdout.writeln();
    stdout.writeln('Global options:');
    stdout.writeln(parser.usage);
  }

  if (help) {
    printUsage();
    return;
  }

  var displayVersion = argResults['version'] as bool;

  if (displayVersion) {
    stdout.write('$currentScriptName version $version');
    stdout.writeln('VM: ${Platform.resolvedExecutable} ${Platform.version}');
    return;
  }

  // handle stdin if asked for it
  if (argResults['stdin'] as bool) {
    if (verbose!) {
      //stderr.writeln('stdin  $stdin');
      //stderr.writeln('stdin  ${await stdin..isEmpty}');
    }
    final lineSync = stdin.readLineSync();
    if (lineSync != null) {
      stdout.write(lineSync);
    }
  }
  // handle stdout
  var outputText = argResults['stdout'] as String?;
  if (outputText != null) {
    stdout.write(outputText);
  }
  var hexOutputText = argResults['stdout-hex'] as String?;
  if (hexOutputText != null) {
    stdout.add(parseHexString(hexOutputText));
  }
  // handle stderr
  var stderrText = argResults['stderr'] as String?;
  if (stderrText != null) {
    stderr.write(stderrText);
  }
  var stderrHexTest = argResults['stderr-hex'] as String?;
  if (stderrHexTest != null) {
    stderr.add(parseHexString(stderrHexTest));
  }

  // handle the rest, default to output
  for (final rest in argResults.rest) {
    stdout.writeln(rest);
  }

  // exit code!
  var exitCodeText = argResults['exit-code'] as String?;
  if (exitCodeText != null) {
    exit(int.parse(exitCodeText));
  }
}
