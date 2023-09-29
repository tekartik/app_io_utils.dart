import 'package:tekartik_app_args/arg_parser.dart';

/// dart run example/dump_args.dart --help --option=value
void main(List<String> arguments) {
  print('args: $arguments');

  var helpFlag = Flag.arg('help', shortcut: 'h');
  var testOption = Option.arg('option', shortcut: 'o');
  var argParser = ArgumentParser()..addArguments([helpFlag, testOption]);
  argParser.parse(arguments);
  print('$helpFlag');
  print('$testOption');
}
