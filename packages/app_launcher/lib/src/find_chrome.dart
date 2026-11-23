import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:process_run/shell.dart';

/// The commands looked for on the path, in order.
const _commands = [
  'google-chrome',
  'google-chrome-stable',
  'chromium',
  'chromium-browser',
  'chrome',
];

/// The Chrome of a macOS install.
const _macApp = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';

/// The Chrome executable, to start it with options (headless, a DevTools
/// port) rather than open a page for the user (`launchChrome` does that):
/// `CHROME_EXECUTABLE` (environment or the process_run user env file), else
/// the first Chrome or Chromium found on the path, else the usual install
/// location: the macOS app, on Windows `Google\Chrome\Application\chrome.exe`
/// under `ProgramFiles`, `ProgramFiles(x86)` or `LOCALAPPDATA`.
///
/// Throws a [StateError] when none is found.
///
/// [operatingSystem] (a `Platform.operatingSystem` value), [environment]
/// (process_run's `userEnvironment` by default), [which] (`whichSync`) and
/// [exists] (a file exists) replace this host's, for tests.
String findChromeExecutable({
  String? operatingSystem,
  Map<String, String>? environment,
  String? Function(String command)? which,
  bool Function(String path)? exists,
}) {
  operatingSystem ??= Platform.operatingSystem;
  environment ??= userEnvironment;
  which ??= (command) => whichSync(command, environment: environment);
  exists ??= (path) => File(path).existsSync();
  var executable = environment['CHROME_EXECUTABLE'];
  if (executable != null) {
    return executable;
  }
  for (var command in _commands) {
    var path = which(command);
    if (path != null) {
      return path;
    }
  }
  switch (operatingSystem) {
    case 'macos':
      if (exists(_macApp)) {
        return _macApp;
      }
    case 'windows':
      for (var variable in const [
        'ProgramFiles',
        'ProgramFiles(x86)',
        'LOCALAPPDATA',
      ]) {
        var base = environment[variable];
        if (base != null) {
          var path = p.windows.join(
            base,
            'Google',
            'Chrome',
            'Application',
            'chrome.exe',
          );
          if (exists(path)) {
            return path;
          }
        }
      }
  }
  throw StateError('Chrome not found: set CHROME_EXECUTABLE');
}
