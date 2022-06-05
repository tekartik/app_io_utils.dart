import 'dart:io';

import 'package:process_run/shell.dart';

/// Returns true if the editor was launched or is terminated...no garantuee
Future<bool> launchTextEdit(String path,
    {bool verbose = false, bool doNotCreate = false}) async {
  if (!doNotCreate) {
    var file = File(path);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
  }
  Future doRun(String command) async {
    await run(command, commandVerbose: verbose);
  }

  path = shellArgument(path);
  if (Platform.isLinux) {
    if (await which('gedit') != null) {
      await doRun('gedit $path');
      return true;
    }
  } else if (Platform.isWindows) {
    if (await which('notepad') != null) {
      await doRun('notepad $path');
      return true;
    }
  } else if (Platform.isMacOS) {
    if (await which('open') != null) {
      await doRun('open -a TextEdit $path');
      return true;
    }
  }
  if (await which('vi') != null) {
    await doRun('vi $path');
    return true;
  }
  return false;
}
