import 'package:args/args.dart' as args;
import 'package:tekartik_app_args/app_args.dart';

import 'argument.dart';

extension TerkartikArgParserExt on args.ArgParser {
  /// Adds [argument] with its default value ([Argument.defaultsTo]), never
  /// the value a previous parse gave it.
  void addArgument(Argument argument) {
    if (argument is Flag) {
      addFlag(
        argument.name,
        abbr: argument.abbr,
        help: argument.help,
        // Not null, the parsed value is cast to bool.
        defaultsTo: argument.defaultsTo ?? false,
        negatable: argument.negatable,
        hide: argument.hide,
      );
    } else if (argument is Option) {
      addOption(
        argument.name,
        abbr: argument.abbr,
        help: argument.help,
        defaultsTo: argument.defaultsTo,
        hide: argument.hide,
      );
    } else if (argument is MultiOption) {
      addMultiOption(
        argument.name,
        abbr: argument.abbr,
        help: argument.help,
        defaultsTo: argument.defaultsTo,
        hide: argument.hide,
      );
    } else {
      throw UnsupportedError(
        'invalid argument "$argument" (${argument.runtimeType})',
      );
    }
  }
}

/// Type safe parser
class ArgumentParser {
  final raw = args.ArgParser();
  final _arguments = <Argument>[];

  void addArgument(Argument argument) {
    _arguments.add(argument);
    raw.addArgument(argument);
  }

  void addArguments(List<Argument> arguments) {
    for (var argument in arguments) {
      addArgument(argument);
    }
  }

  ArgumentResults parse(List<String> args) {
    var rawResults = raw.parse(args);
    return ArgumentResults(arguments: _arguments, raw: rawResults);
  }
}

class ArgumentResults {
  final args.ArgResults raw;

  ArgumentResults({List<Argument>? arguments, required this.raw}) {
    if (arguments != null) {
      for (var argument in arguments) {
        var value = raw[argument.name];
        argument.base.setValueFrom(value);
        //print('$argument: $value');
      }
    }
  }
}
