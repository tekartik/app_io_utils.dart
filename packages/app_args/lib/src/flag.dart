import 'argument.dart';

abstract class Flag implements Argument<bool> {
  bool get on;

  factory Flag.arg(String name, {String? shortcut, bool? on, String? help}) =>
      _Flag(name, shortcut: shortcut, on: on ?? false, help: help);
}

class _Flag extends ArgumentBase<bool> implements Flag {
  @override
  bool on;

  _Flag(super.name,
      {required super.shortcut, required this.on, required super.help});

  @override
  bool? get value => on;

  @override
  void setValueFrom(Object? value) {
    /// typically this is a bool
    on = value as bool;
  }
}

final flagHelp = Flag.arg('help', shortcut: 'h', help: 'Display help');
