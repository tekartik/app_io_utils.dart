import 'dart:io';

import 'package:process_run/shell.dart';
import 'package:tekartik_app_io_launcher/launcher.dart';

import 'launch_utils.dart';
import 'utils.dart';

/// Launch default viewer for a given path
Future<bool> launchDefaultViewerPath(
  String path, {
  bool verbose = false,
}) async {
  return launchDefaultViewer(pathToUriDefaultToFile(path), verbose: verbose);
}

/// Launch default viewer for a given uri (falls back to chrome).
///
/// Returns false when nothing could be launched.
Future<bool> launchDefaultViewer(Uri uri, {bool verbose = false}) async {
  var url = shellArgument(uri.toString());
  if (await which('xdg-open') != null) {
    return await runLaunchCommand('xdg-open $url', verbose: verbose);
  }
  if (Platform.isMacOS) {
    if (await which('open') != null) {
      return await runLaunchCommand('open $url', verbose: verbose);
    }
  } else if (Platform.isWindows) {
    // Somehow it returns an exit code of 1...
    await runLaunchCommand('explorer $url', verbose: verbose);
    return true;
  }

  return launchChrome(uri, verbose: verbose);
}
