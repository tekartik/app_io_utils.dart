import 'argument.dart';

abstract class Option implements Argument<String> {
  factory Option.arg(
    String name, {
    String? abbr,
    String? help,
    String? defaultsTo,
    bool? hide,
  }) {
    var option = _Option();
    option.name = name;
    option.abbr = abbr;
    option.help = help;
    option.defaultsTo = defaultsTo;
    option.hide = hide ?? false;

    // Specific
    option.value = defaultsTo;
    return option;
  }
}

class _Option extends ArgumentBase<String> implements Option {
  _Option();

  @override
  String? value;

  @override
  void setValueFrom(Object? value) {
    /// typically this is a bool
    this.value = value as String?;
  }
}
