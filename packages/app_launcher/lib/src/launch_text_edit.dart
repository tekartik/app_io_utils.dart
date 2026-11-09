import 'dart:io';

import 'package:process_run/shell.dart';

import 'launch_utils.dart';

/// Open [path] in a text editor: gedit (Linux), notepad (Windows), TextEdit
/// (macOS); false when none is found. The file is created when missing
/// unless [doNotCreate] is true.
///
/// Completes when the editor command exits: when the editor was not running
/// yet, that is when its window is closed.
Future<bool> launchTextEdit(
  String path, {
  bool verbose = false,
  bool doNotCreate = false,
}) async {
  if (!doNotCreate) {
    var file = File(path);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
  }

  path = shellArgument(path);
  if (Platform.isLinux) {
    if (await which('gedit') != null) {
      return await runLaunchCommand('gedit $path', verbose: verbose);
    }
  } else if (Platform.isWindows) {
    if (await which('notepad') != null) {
      return await runLaunchCommand('notepad $path', verbose: verbose);
    }
  } else if (Platform.isMacOS) {
    if (await which('open') != null) {
      return await runLaunchCommand('open -a TextEdit $path', verbose: verbose);
    }
  }
  // No vi fallback: run without a terminal (and with an open stdin) it waits
  // forever, the call would never return.
  return false;
}
