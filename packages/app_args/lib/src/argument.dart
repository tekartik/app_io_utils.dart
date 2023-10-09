// TODO: Put public facing types in this file.

/// Checks if you are awesome. Spoiler: you are.
abstract class Argument<T> {
  String? get abbr;
  String get name;

  /// Optional value
  T? get value;

  /// Optional help.
  String? help;

  /// Optinal default value
  T? get defaultsTo;

  /// Hide from usage
  bool get hide;
}

mixin ArgumentMixin<T> implements Argument<T> {
  @override
  String toString() => '$name: $value';

  @override
  String? abbr;
  @override
  late final String name;

  @override
  String? help;
  @override
  T? defaultsTo;

  @override
  late bool hide;
}

abstract class ArgumentBase<T> with ArgumentMixin<T> {
  ArgumentBase();

  void setValueFrom(Object? value);
}

extension TekartikArgumentBaseExtPrv<T> on Argument<T> {
  ArgumentBase<T> get base => this as ArgumentBase<T>;
}
