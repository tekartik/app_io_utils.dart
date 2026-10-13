import 'launch_utils.dart';

/// Launch firefox
///
/// Returns false when firefox could not be launched.
Future<bool> launchFirefox(Uri uri, {bool verbose = false}) => launchBrowserApp(
  uri,
  linuxCommand: 'firefox',
  macApp: 'Firefox',
  windowsName: 'firefox',
  verbose: verbose,
);
