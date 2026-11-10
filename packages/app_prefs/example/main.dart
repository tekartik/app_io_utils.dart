// ignore_for_file: avoid_print

import 'package:tekartik_app_io_prefs/app_prefs.dart';

/// Counts its runs (`dart run example/main.dart`).
Future<void> main() async {
  // One factory per package name, the same instance at every call.
  var prefsFactory = getPrefsFactory(packageName: 'com.example.my_tool');
  var prefs = await prefsFactory.openPreferences('settings');

  var runCount = (prefs.getInt('run_count') ?? 0) + 1;
  print('run #$runCount, title ${prefs.getString('title')}');

  // Writes are synchronous, saved in the background: save (or close)
  // before the program exits.
  prefs.setInt('run_count', runCount);
  await prefs.close();
}
