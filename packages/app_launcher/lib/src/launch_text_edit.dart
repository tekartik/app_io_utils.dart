import 'dart:io';

import 'package:process_run/shell.dart';

/// Returns true if the editor was launched or is terminated...no garantuee
Future<bool> launchTextEdit(String path, {bool verbose = false}) async {
  Future _run(String command) async {
    await run(command, commandVerbose: verbose);
  }

  path = shellArgument(path);
  if (Platform.isLinux) {
    if (await which('gedit') != null) {
      await _run('gedit $path');
      return true;
    }
  } else if (Platform.isWindows) {
    if (await which('notepad') != null) {
      await _run('notepad $path');
      return true;
    }
  } else if (Platform.isMacOS) {
    if (await which('open') != null) {
      await _run('open -a TextEdit $path');
      return true;
    }
  }
  if (await which('vi') != null) {
    await _run('vi $path');
    return true;
  }
  return false;
}