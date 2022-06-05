import 'dart:io';

import 'package:process_run/shell.dart';

/// Launch file explorer
///
/// Linux (nautilus) only for now
Future<bool> launchFileExplorer(String path, {bool verbose = false}) async {
  Future doRun(String command) async {
    await run(command, commandVerbose: verbose);
  }

  path = shellArgument(path);
  if (Platform.isLinux) {
    if (await which('nautilus') != null) {
      await doRun('nautilus $path');
      return true;
    }
  } else if (Platform.isMacOS) {
    if (await which('open') != null) {
      await doRun('open $path');
      return true;
    }
  } else if (Platform.isWindows) {
    await doRun('start $path');
    return true;
  }
  return false;
}
