---
name: tekartik-app-args-parser
description: >-
  Use when parsing command line arguments in a Dart CLI with typed argument
  objects from tekartik_app_args instead of raw package:args lookups:
  ArgumentParser, ArgumentResults, Flag.arg and flag.on, Option.arg and
  option.value, MultiOption.arg and multiOption.list, the shared flagHelp,
  the TerkartikArgParserExt.addArgument extension on an existing ArgParser
  (CommandRunner commands), raw.usage / raw.rest, and the arg_parser.dart or
  app_args.dart imports.
---

# Typed argument parsing (tekartik_app_args)

`tekartik_app_args` wraps `package:args`: each flag or option is declared as
an object (`Flag`, `Option`, `MultiOption`), registered on an
`ArgumentParser`, and after `parse` the typed value is read from the object
(`flag.on`, `option.value`, `multiOption.list`) instead of indexing an
`ArgResults` by string name.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_app_args:
      git:
        url: https://github.com/tekartik/app_io_utils.dart
        path: packages/app_args
      version: '>=0.1.0'
  ```
  It depends on `args`; declare `args` yourself as well when you import
  `package:args/args.dart` or `package:args/command_runner.dart`.
* Imports: `package:tekartik_app_args/arg_parser.dart` is the one to use. It
  exports `ArgumentParser`, `ArgumentResults`, `TerkartikArgParserExt` and
  everything of `package:tekartik_app_args/app_args.dart` (`Argument`,
  `Flag`, `Option`, `MultiOption`, `flagHelp`). Import `app_args.dart` alone
  in a library that only declares arguments.
* Declare arguments once (top-level finals or class fields) with the named
  factories:
  - `Flag.arg(name, {abbr, help, defaultsTo, negatable, hide})`: read
    `flag.on` (`bool`, `defaultsTo ?? false` when not passed). `negatable`
    defaults to true (`--no-<name>` is accepted); use `negatable: false` for
    `--help` style flags.
  - `Option.arg(name, {abbr, help, defaultsTo, hide})`: read `option.value`
    (`String?`, null when not passed and no `defaultsTo`).
  - `MultiOption.arg(name, {abbr, help, defaultsTo, hide})`: read
    `multiOption.list` (`List<String>`, empty when not passed; `--opt=a,b`
    and repeated `--opt a --opt b` both give `[a, b]`, package:args rules).
    `list` is `value!`: before the first `parse` it throws unless a
    `defaultsTo` was given; `value` is the nullable form.
  - `flagHelp` is a ready made
    `Flag.arg('help', abbr: 'h', help: 'Display help', negatable: false)`.
  All of them are `Argument<T>`: `name`, `abbr`, `help`, `defaultsTo`,
  `hide`, `value`; `toString()` prints `'$name: $value'`.
* Parser: `var parser = ArgumentParser()..addArguments([flagHelp, verbose]);`
  (`addArgument` for a single one). `parser.parse(args)` fills the objects
  (each parse overwrites the previous values; arguments not passed get their
  default back) and returns an `ArgumentResults` whose `raw` is the
  package:args `ArgResults`: use it for `rest`, `wasParsed(name)`,
  `command`. Ignore the return value when the objects are all you need.
* `parser.raw` is the underlying `ArgParser`: `parser.raw.usage` gives the
  help text, `parser.raw.addCommand(...)` adds sub-commands. `parse` throws
  a `FormatException` (`ArgParserException`) on an unknown option or a
  missing option value: catch it, print the message and `usage`, exit with a
  non zero code.
* Existing `ArgParser` (a `Command` from `package:args/command_runner.dart`,
  or code that already built an `ArgParser`): `argParser.addArgument(flag)`
  (extension `TerkartikArgParserExt`) registers the object with the right
  `addFlag`/`addOption`/`addMultiOption` call; after parsing,
  `ArgumentResults(arguments: [flag, option], raw: argResults)` copies the
  parsed values into the objects.
* The argument objects hold state: never register the same object on two
  parsers (package:args throws on a duplicate name, and the values would be
  overwritten by whichever parsed last). `flagHelp` is a global: fine for
  the single `main` of a CLI, use a local `Flag.arg('help', ...)` in tests
  that build several parsers.
* Tests (`dart test`): build a parser with local arguments, call
  `parse(['--flag', '--opt=value'])` and `expect` on `.on`, `.value`,
  `.list`; parse `[]` again to check the defaults.

## Examples

### Command line tool with help, flag, option, multi option and rest args

```dart
import 'dart:io';

import 'package:tekartik_app_args/arg_parser.dart';

final verboseFlag = Flag.arg('verbose', abbr: 'v', help: 'Verbose output');
final outputOption = Option.arg(
  'output',
  abbr: 'o',
  help: 'Output directory',
  defaultsTo: 'build',
);
final defineOption = MultiOption.arg(
  'define',
  abbr: 'D',
  help: 'key=value definitions (repeatable or comma separated)',
);

/// dart run bin/build.dart -v -o out -D a=1,b=2 src/main.dart
void main(List<String> arguments) {
  var parser = ArgumentParser()
    ..addArguments([flagHelp, verboseFlag, outputOption, defineOption]);
  ArgumentResults results;
  try {
    results = parser.parse(arguments);
  } on FormatException catch (e) {
    stderr.writeln(e.message);
    stderr.writeln(parser.raw.usage);
    exit(64);
  }
  if (flagHelp.on) {
    stdout.writeln('Usage: build [options] <files>');
    stdout.writeln(parser.raw.usage);
    return;
  }
  var files = results.raw.rest;
  if (files.isEmpty) {
    stderr.writeln('missing input files');
    exit(64);
  }
  if (verboseFlag.on) {
    stdout.writeln('$outputOption, $defineOption, files: $files');
  }
  var defines = <String, String>{
    for (var define in defineOption.list)
      define.split('=').first: define.split('=').skip(1).join('='),
  };
  stdout.writeln('output ${outputOption.value} defines $defines');
}
```

### Typed arguments on a CommandRunner command

```dart
import 'package:args/command_runner.dart';
import 'package:tekartik_app_args/arg_parser.dart';

class ServeCommand extends Command<void> {
  @override
  final name = 'serve';
  @override
  final description = 'Start the dev server';

  final portOption = Option.arg('port', abbr: 'p', defaultsTo: '8080');
  final openFlag = Flag.arg('open', help: 'Open the browser', negatable: false);

  ServeCommand() {
    // TerkartikArgParserExt on the package:args ArgParser
    argParser
      ..addArgument(portOption)
      ..addArgument(openFlag);
  }

  @override
  Future<void> run() async {
    // Copy the parsed values into the typed objects
    ArgumentResults(arguments: [portOption, openFlag], raw: argResults!);
    var port = int.parse(portOption.value!);
    print('serving on $port${openFlag.on ? ', opening the browser' : ''}');
  }
}

Future<void> main(List<String> arguments) async {
  var runner = CommandRunner<void>('tool', 'Dev tool')
    ..addCommand(ServeCommand());
  await runner.run(arguments);
}
```

### Unit test

```dart
import 'package:tekartik_app_args/arg_parser.dart';
import 'package:test/test.dart';

void main() {
  test('parse', () {
    var helpFlag = Flag.arg('help', abbr: 'h', negatable: false);
    var nameOption = Option.arg('name', defaultsTo: 'world');
    var tags = MultiOption.arg('tag', defaultsTo: []);
    var parser = ArgumentParser()..addArguments([helpFlag, nameOption, tags]);

    var results = parser.parse(['-h', '--tag=a,b', '--tag', 'c', 'rest']);
    expect(helpFlag.on, isTrue);
    expect(nameOption.value, 'world');
    expect(tags.list, ['a', 'b', 'c']);
    expect(results.raw.rest, ['rest']);

    parser.parse([]);
    expect(helpFlag.on, isFalse);
    expect(tags.list, isEmpty);
    expect(() => parser.parse(['--unknown']), throwsFormatException);
  });
}
```

## Common mistakes

* Reading `multiOption.list` before any parse and without `defaultsTo`
  (null check error): parse first, or read `value ?? []`.
* Treating `option.value` as non null: it is `String?`; give a `defaultsTo`
  or check it.
* Adding `flagHelp` to the parser but never testing `flagHelp.on` nor
  printing `parser.raw.usage`.
* Calling both `parser.addArgument(x)` and `parser.raw.addArgument(x)`:
  `ArgumentParser.addArgument` already registers the argument on `raw`.
