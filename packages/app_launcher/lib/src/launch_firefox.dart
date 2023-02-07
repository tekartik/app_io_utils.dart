import 'dart:io';

import 'package:process_run/shell.dart';

/// Launch firefox
///
/// Linux only for now
Future<bool> launchFirefox(Uri uri, {bool verbose = false}) async {
  Future doRun(String command) async {
    await run(command, commandVerbose: verbose);
  }

  var url = shellArgument(uri.toString());
  if (await which('firefox') != null) {
    await doRun('firefox $url');
    return true;
  }
  if (Platform.isMacOS) {
    // TO TEST
    if (await which('open') != null) {
      await doRun('open -a "Firefox" $url');
      return true;
    }
  } else if (Platform.isWindows) {
    // TO TEST
    await doRun('start firefox $url');
    return true;
  }
  return false;
}
