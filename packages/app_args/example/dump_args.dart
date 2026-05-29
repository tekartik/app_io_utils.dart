import 'dart:io';

import 'package:tekartik_app_args/arg_parser.dart';

/// dart run example/dump_args.dart --help --option=value
void main(List<String> arguments) {
  stdout.writeln('args: $arguments');

  //var helpFlag = Flag.arg('help', abbr: 'h');
  var testOption = Option.arg('option', abbr: 'o');
  var argParser = ArgumentParser()..addArguments([flagHelp, testOption]);
  argParser.parse(arguments);
  stdout.writeln('$flagHelp');
  stdout.writeln('$testOption');

  if (flagHelp.on) {
    stdout.writeln(argParser.raw.usage);
  }
}
