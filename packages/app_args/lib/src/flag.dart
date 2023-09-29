import 'argument.dart';

abstract class Flag implements Argument<bool> {
  /// The parsed value of this flag.
  bool get on;

  /// Whether this flag can be negated.
  bool get negatable;

  factory Flag.arg(String name,
      {String? abbr,
      String? help,
      bool? defaultsTo,
      bool? negatable,
      bool? hide}) {
    var flag = _Flag();
    flag.name = name;
    flag.abbr = abbr;
    flag.help = help;
    flag.defaultsTo = defaultsTo;
    flag.hide = hide ?? false;
    // flag only
    flag.on = defaultsTo ?? false;
    flag.negatable = negatable ?? true;
    return flag;
  }
}

class _Flag extends ArgumentBase<bool> implements Flag {
  @override
  late bool on;

  @override
  late bool negatable;

  _Flag();

  @override
  bool? get value => on;

  @override
  void setValueFrom(Object? value) {
    /// typically this is a bool
    on = value as bool;
  }
}

final flagHelp =
    Flag.arg('help', abbr: 'h', help: 'Display help', negatable: false);
