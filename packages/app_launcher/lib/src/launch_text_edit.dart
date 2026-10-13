import 'dart:io';

import 'package:process_run/shell.dart';

import 'launch_utils.dart';

/// Returns true if the editor was launched or is terminated...no garantuee
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
  if (await which('vi') != null) {
    return await runLaunchCommand('vi $path', verbose: verbose);
  }
  return false;
}
