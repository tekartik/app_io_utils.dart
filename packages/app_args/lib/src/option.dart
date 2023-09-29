import 'argument.dart';

abstract class Option implements Argument<String> {
  factory Option.arg(String name,
          {String? shortcut, String? value, String? help}) =>
      _Option(name, shortcut: shortcut, value: value, help: help);
}

class _Option extends ArgumentBase<String> implements Option {
  _Option(super.name,
      {required super.shortcut, required this.value, required super.help});

  @override
  String? value;

  @override
  void setValueFrom(Object? value) {
    /// typically this is a bool
    this.value = value as String?;
  }
}
