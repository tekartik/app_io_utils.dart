// TODO: Put public facing types in this file.

/// Checks if you are awesome. Spoiler: you are.
abstract class Argument<T> {
  String? get shortcut;
  String get name;

  /// Optional value
  T? get value;

  /// Optional help.
  String? help;
}

mixin ArgumentMixin<T> implements Argument<T> {
  @override
  String toString() => '$name: $value';
}

abstract class ArgumentBase<T> with ArgumentMixin<T> {
  @override
  String? shortcut;
  @override
  late String name;

  @override
  String? help;
  //@override
  //T? get value => throw UnimplementedError();

  ArgumentBase(this.name, {this.shortcut, required this.help});

  void setValueFrom(Object? value);
}

extension TekartikArgumentBaseExtPrv<T> on Argument<T> {
  ArgumentBase<T> get base => this as ArgumentBase<T>;
}
