import 'package:tekartik_app_args/arg_parser.dart';
import 'package:test/test.dart';

void main() {
  group('arg_parser', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('parse help', () {
      var helpFlag = Flag.arg('help', abbr: 'h');
      var argParser = ArgumentParser();
      argParser.addArgument(helpFlag);
      // ignore: unused_local_variable
      var result = argParser.parse(['--help']);
      expect(helpFlag.name, 'help');
      expect(helpFlag.on, isTrue);
      expect(helpFlag.value, isTrue);
      result = argParser.parse([]);
      expect(helpFlag.name, 'help');
      expect(helpFlag.on, isFalse);
      expect(helpFlag.value, isFalse);
    });
    test('parse option', () {
      var testOption = Option.arg('option', abbr: 'o');
      var argParser = ArgumentParser();
      argParser.addArgument(testOption);
      // ignore: unused_local_variable
      var result = argParser.parse(['--option', 'value']);
      expect(testOption.name, 'option');
      expect(testOption.value, 'value');
      argParser.parse([]);
      expect(testOption.name, 'option');
      expect(testOption.value, isNull);
      argParser.parse(['--option=value']);
      expect(testOption.name, 'option');
      expect(testOption.value, 'value');
    });
    test('parse multi option', () {
      var testOption = MultiOption.arg('option', abbr: 'o');
      var argParser = ArgumentParser();
      argParser.addArgument(testOption);
      // ignore: unused_local_variable
      var result = argParser.parse(['--option', 'value']);
      expect(testOption.name, 'option');
      expect(testOption.value, ['value']);
      argParser.parse([]);
      expect(testOption.name, 'option');
      expect(testOption.value, isEmpty);
      expect(testOption.list, isEmpty);
      argParser.parse(['--option=value1,value2']);
      expect(testOption.name, 'option');
      expect(testOption.value, ['value1', 'value2']);
    });
  });
}
