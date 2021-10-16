import 'dart:io';

import 'package:process_run/shell.dart';

/// Launch chrome
///
/// Linux only for now
Future<bool> launchChrome(Uri uri, {bool verbose = false}) async {
  Future _run(String command) async {
    await run(command, commandVerbose: verbose);
  }

  var url = shellArgument(uri.toString());
  if (await which('google-chrome') != null) {
    await _run('google-chrome $url');
    return true;
  }
  if (Platform.isMacOS) {
    if (await which('open') != null) {
      await _run('open -a "Google Chrome" $url');
      return true;
    }
  } else if (Platform.isWindows) {
    await _run('start chrome $url');
    return true;
  }
  return false;
}
