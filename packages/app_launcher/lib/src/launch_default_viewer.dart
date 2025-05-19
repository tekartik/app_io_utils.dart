import 'dart:io';

import 'package:process_run/shell.dart';
import 'package:tekartik_app_io_launcher/launcher.dart';

import 'utils.dart';

/// Launch default viewer for a given path
Future<bool> launchDefaultViewerPath(
  String path, {
  bool verbose = false,
}) async {
  return launchDefaultViewer(pathToUriDefaultToFile(path), verbose: verbose);
}

/// Launch default
///
Future<bool> launchDefaultViewer(Uri uri, {bool verbose = false}) async {
  Future doRun(String command) async {
    await run(command, commandVerbose: verbose);
  }

  var url = shellArgument(uri.toString());
  if (await which('xdg-open') != null) {
    await doRun('xdg-open $url');
    return true;
  }
  if (Platform.isMacOS) {
    if (await which('open') != null) {
      await doRun('open $url');
      return true;
    }
  } else if (Platform.isWindows) {
    try {
      // Somehow it returns an exit code of 1...
      await doRun('explorer $url');
    } catch (_) {}
    return true;
  }
  return launchChrome(uri, verbose: verbose);
}
