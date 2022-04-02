import 'dart:io';

import 'package:tekartik_app_io_platform/platform.dart' as p;
import 'package:test/test.dart';

void main() async {
  group('platform_io', () {
    test('isXxx vs flutter test', () {});
    test('isXxx', () {
      if (Platform.isMacOS) {
        expect(p.isMacOS, isTrue);
        expect(p.isLinux, isFalse);
        expect(p.isWindows, isFalse);
      } else if (Platform.isLinux) {
        expect(p.isMacOS, isFalse);
        expect(p.isLinux, isTrue);
        expect(p.isWindows, isFalse);
      } else if (Platform.isWindows) {
        expect(p.isMacOS, isFalse);
        expect(p.isLinux, isFalse);
        expect(p.isWindows, isTrue);
      }
      // Never true in host platforms
      expect(p.isAndroid, isFalse);
      // Never true in host platforms
      expect(p.isIOS, isFalse);
    });
  });
}
