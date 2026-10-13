import 'launch_utils.dart';

/// Launch chrome
///
/// Returns false when chrome could not be launched.
Future<bool> launchChrome(Uri uri, {bool verbose = false}) => launchBrowserApp(
  uri,
  linuxCommand: 'google-chrome',
  macApp: 'Google Chrome',
  windowsName: 'chrome',
  verbose: verbose,
);
