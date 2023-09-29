import 'package:tekartik_app_args/arg_parser.dart';

/// dart run example/dump_args.dart --help --option=value
void main(List<String> arguments) {
  print('args: $arguments');

  //var helpFlag = Flag.arg('help', abbr: 'h');
  var testOption = Option.arg('option', abbr: 'o');
  var argParser = ArgumentParser()..addArguments([flagHelp, testOption]);
  argParser.parse(arguments);
  print('$flagHelp');
  print('$testOption');

  if (flagHelp.on) {
    print(argParser.raw.usage);
  }
}
