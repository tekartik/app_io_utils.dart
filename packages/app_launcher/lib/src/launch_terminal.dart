import 'dart:io';

import 'package:process_run/shell.dart';

import 'launch_terminal_options.dart';

export 'launch_terminal_options.dart' show LaunchTerminalOptions;

/// Launch terminal.
///
/// Spawns a new terminal window.
Future<bool> launchTerminal({
  LaunchTerminalOptions? options,
  bool verbose = false,
}) async {
  Future doRun(String command, {String? workingDirectory}) async {
    await run(
      command,
      commandVerbose: verbose,
      workingDirectory: workingDirectory,
    );
  }

  var directoryPath = options?.directoryPath;
  if (directoryPath != null) {
    directoryPath = Directory(directoryPath).absolute.path;
  }

  if (Platform.isLinux) {
    if (await which('xdg-terminal-exec') != null) {
      await doRun('xdg-terminal-exec', workingDirectory: directoryPath);
      return true;
    }
    if (await which('x-terminal-emulator') != null) {
      await doRun('x-terminal-emulator', workingDirectory: directoryPath);
      return true;
    }
    if (await which('gnome-terminal') != null) {
      var dirArg = directoryPath != null
          ? ' --working-directory=${shellArgument(directoryPath)}'
          : '';
      await doRun('gnome-terminal$dirArg');
      return true;
    }
    if (await which('xfce4-terminal') != null) {
      var dirArg = directoryPath != null
          ? ' --working-directory=${shellArgument(directoryPath)}'
          : '';
      await doRun('xfce4-terminal$dirArg');
      return true;
    }
    if (await which('konsole') != null) {
      var dirArg = directoryPath != null
          ? ' --workdir ${shellArgument(directoryPath)}'
          : '';
      await doRun('konsole$dirArg');
      return true;
    }
  } else if (Platform.isMacOS) {
    if (await which('open') != null) {
      var dir = directoryPath ?? '.';
      await doRun('open -a Terminal ${shellArgument(dir)}');
      return true;
    }
  } else if (Platform.isWindows) {
    await doRun('start cmd', workingDirectory: directoryPath);
    return true;
  }
  return false;
}
