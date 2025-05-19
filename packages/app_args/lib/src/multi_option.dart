import 'argument.dart';

abstract class MultiOption implements Argument<List<String>> {
  List<String> get list;

  factory MultiOption.arg(
    String name, {
    String? abbr,
    String? help,
    List<String>? defaultsTo,
    bool? hide,
  }) {
    var option = _MultiOption();
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

class _MultiOption extends ArgumentBase<List<String>> implements MultiOption {
  _MultiOption();

  @override
  List<String>? value;

  @override
  void setValueFrom(Object? value) {
    /// typically this is a bool
    this.value = value as List<String>?;
  }

  @override
  List<String> get list => value!;
}
