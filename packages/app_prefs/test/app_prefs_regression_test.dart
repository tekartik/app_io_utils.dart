@TestOn('vm')
library;

import 'dart:io';

import 'package:process_run/shell.dart';
import 'package:tekartik_app_io_prefs/app_prefs.dart';
import 'package:test/test.dart';

void main() {
  late Directory top;
  setUpAll(() async {
    top = await Directory.systemTemp.createTemp('app_io_prefs');
    // Never the real user data folder
    platformEnvironment = {
      ...platformEnvironment,
      'TEKARTIK_PROCESS_RUN_USER_APP_DATA_PATH': top.path,
    };
  });
  tearDownAll(() async {
    platformEnvironment = null;
    await top.delete(recursive: true);
  });
  group('prefs factory', () {
    test('one factory per package name', () {
      expect(prefsFactory, same(prefsFactory));
      expect(getPrefsFactory(), same(getPrefsFactory()));
      expect(getPrefsFactory(), same(prefsFactory));
      expect(
        getPrefsFactory(packageName: 'tekartik.app_io_prefs.test'),
        same(getPrefsFactory(packageName: 'tekartik.app_io_prefs.test')),
      );
    });
    test('same prefs opened twice', () async {
      var name = 'same_prefs';
      try {
        var prefs1 = await prefsFactory.openPreferences(name);
        var prefs2 = await getPrefsFactory().openPreferences(name);
        prefs1.setInt('value', 1);
        await prefs1.save();
        // Read back through the second reference
        expect(prefs2.getInt('value'), 1);
      } finally {
        await prefsFactory.deletePreferences(name);
      }
    });
  }, timeout: const Timeout(Duration(seconds: 30)));
}
