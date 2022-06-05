import 'dart:io';

import 'package:process_run/shell.dart';

/// Launch chrome
///
/// Linux only for now
Future<bool> launchChrome(Uri uri, {bool verbose = false}) async {
  Future doRun(String command) async {
    await run(command, commandVerbose: verbose);
  }

  var url = shellArgument(uri.toString());
  if (await which('google-chrome') != null) {
    await doRun('google-chrome $url');
    return true;
  }
  if (Platform.isMacOS) {
    if (await which('open') != null) {
      await doRun('open -a "Google Chrome" $url');
      return true;
    }
  } else if (Platform.isWindows) {
    await doRun('start chrome $url');
    return true;
  }
  return false;
}
