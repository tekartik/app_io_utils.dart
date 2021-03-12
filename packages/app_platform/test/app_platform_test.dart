import 'package:test/test.dart';
import 'package:tekartik_app_io_platform/app_platform.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';

void main() async {
  group('public', () {
    test('def', () {
      // ignore: unnecessary_statements
      platformInit;
      // ignore: unnecessary_statements
      platformContext;
      // ignore: unnecessary_statements
      PlatformContext;
    });
  });
  group('platform', () {
    test('context', () {
      expect(platformContext, isNotNull);
      print(jsonPretty(platformContext.toMap()));
    });
  });
}
